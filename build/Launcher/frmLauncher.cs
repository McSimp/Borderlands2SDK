using Microsoft.Win32;
using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using System.ComponentModel;
using System.Threading;

namespace Launcher
{
    public partial class frmLauncher : Form
    {
        private Thread InjectorThread;
        private string GamePath;

        public frmLauncher()
        {
            CreateInjectorThread();

            InitializeComponent();
        }

        private void CreateInjectorThread()
        {
            this.InjectorThread = new Thread(new ThreadStart(this.WaitAndInject));
            this.InjectorThread.IsBackground = true;
        }

        private string GetStartPath()
        {
            if (txtGamePath.TextLength > 0)
            {
                string currPath = Path.GetDirectoryName(txtGamePath.Text);
                if (Directory.Exists(currPath))
                {
                    return currPath;
                }
            }

            RegistryKey steamAppKey = Registry.LocalMachine.OpenSubKey(@"SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 49520");
            if (steamAppKey != null)
            {
                string installDir = (string)steamAppKey.GetValue("InstallLocation");
                if (!string.IsNullOrEmpty(installDir))
                {
                    string bl2Path = Path.GetFullPath(Path.Combine(installDir, "Binaries", "Win32"));
                    if (Directory.Exists(bl2Path))
                    {
                        return bl2Path;
                    }
                }
            }

            RegistryKey steamKey = Registry.CurrentUser.OpenSubKey(@"Software\Valve\Steam");
            if (steamKey != null)
            {
                string steamPath = (string)steamKey.GetValue("SteamPath");
                if (!string.IsNullOrEmpty(steamPath))
                {
                    string bl2Path = Path.GetFullPath(Path.Combine(steamPath, "steamapps", "common", "Borderlands2", "Binaries", "Win32"));
                    if (Directory.Exists(bl2Path))
                    {
                        return bl2Path;
                    }
                }
            }

            return string.Empty;
        }

        private string GetAbsoluteGamePath()
        {
            string parent = GetStartPath();
            if (!string.IsNullOrEmpty(parent))
            {
                return Path.Combine(parent, "Borderlands2.exe");
            }
            else
            {
                return string.Empty;
            }
        }

        private void SetupRegistry()
        {
            // Check if we already have our key setup
            RegistryKey SDKSubKey = Registry.CurrentUser.OpenSubKey(@"Software\BL2SDK", RegistryKeyPermissionCheck.ReadWriteSubTree);
            if (SDKSubKey == null)
            {
                // Key doesn't exist, create it
                SDKSubKey = Registry.CurrentUser.CreateSubKey(@"Software\BL2SDK", RegistryKeyPermissionCheck.ReadWriteSubTree);
            }

            string currentDir = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);

            SDKSubKey.SetValue("BinPath", Path.Combine(currentDir + "\\"));
            SDKSubKey.SetValue("LuaPath", Path.Combine(currentDir, "lua\\"));
            SDKSubKey.SetValue("GwenPath", Path.Combine(currentDir, "gwen\\"));
        }

        private void btnBrowse_Click(object sender, EventArgs e)
        {
            OpenFileDialog openFileDialog = new OpenFileDialog();
            openFileDialog.InitialDirectory = GetStartPath();
            openFileDialog.Filter = "Borderlands 2 (*.exe)|*.exe";
            DialogResult result = openFileDialog.ShowDialog();
            if (result == DialogResult.OK)
            {
                txtGamePath.Text = openFileDialog.FileName;
            }
        }

        private void ResetButton()
        {
            btnLaunch.Invoke(new MethodInvoker(
                delegate
                {
                    btnLaunch.Text = "Launch Game";
                    btnLaunch.Enabled = true;
                }
            ));
        }

        private void WaitAndInject()
        {
            DateTime start = DateTime.Now;
            string procName = Path.GetFileNameWithoutExtension(this.GamePath);

            // Wait 30 seconds for Steam to get its shit together
            while ((DateTime.Now - start).Seconds < 30)
            {
                Process[] procs = Process.GetProcessesByName(procName);
                if (procs[0] == null)
                {
                    continue;
                }

                Process bl2Proc = procs[0];

                string currentDir = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);

                // Yuck.
                try
                {
                    Injector.Inject(Path.Combine(currentDir, "BL2SDKDLL.dll"), bl2Proc);
                }
                catch (Win32Exception e)
                {
                    MessageBox.Show("Failed to inject SDK into Borderlands 2. Exception Message = " + e.Message + " Code = " + e.NativeErrorCode, "Failed to launch", MessageBoxButtons.OK, MessageBoxIcon.Error);

                    //Win32.TerminateProcess(lpProcessInformation.hProcess, 0);
                    bl2Proc.Kill();

                    ResetButton();
                    return;
                }
                catch (Exception e)
                {
                    MessageBox.Show("Failed to inject SDK into Borderlands 2. Exception = " + e.Message, "Failed to launch", MessageBoxButtons.OK, MessageBoxIcon.Error);

                    //Win32.TerminateProcess(lpProcessInformation.hProcess, 0);
                    bl2Proc.Kill();

                    ResetButton();
                    return;
                }

                foreach (ProcessThread thread in bl2Proc.Threads)
                {
                    IntPtr hThread = Win32.OpenThread(
                        Win32.ThreadAccessFlags.SuspendResume,
                        false,
                        (uint)thread.Id);

                    Win32.ResumeThread(hThread);
                    Win32.CloseHandle(hThread);
                }

                return;
            }

            MessageBox.Show("Failed to find game after 30 seconds", "Failed to launch", MessageBoxButtons.OK, MessageBoxIcon.Error);
            ResetButton();
        }

        private void btnLaunch_Click(object sender, EventArgs ea)
        {
            if (this.InjectorThread.ThreadState == System.Threading.ThreadState.Stopped)
            {
                // Need to remake the thread
                CreateInjectorThread();
            }

            SetupRegistry();
            
            string gamePath = txtGamePath.Text;
            if (!File.Exists(gamePath))
            {
                MessageBox.Show("Invalid path - could not find Borderlands 2.exe", "Failed to Launch", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            if (Process.GetProcessesByName(Path.GetFileNameWithoutExtension(gamePath)).Length > 0)
            {
                MessageBox.Show("Borderlands 2 is already running. Please close it before trying again.", "Failed to Launch", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            this.GamePath = gamePath;
            string gameDir = Path.GetDirectoryName(gamePath);

            Win32.STARTUPINFO lpStartupInfo = new Win32.STARTUPINFO();

            Environment.SetEnvironmentVariable("SteamGameId", "49520");
            Environment.SetEnvironmentVariable("SteamAppId", "49520");

            Win32.PROCESS_INFORMATION lpProcessInformation;

            bool result = Win32.CreateProcess(
                gamePath,
                "-nolauncher",
                IntPtr.Zero,
                IntPtr.Zero,
                false,
                Win32.CreateProcessFlags.CreateSuspended,
                IntPtr.Zero,
                gameDir,
                ref lpStartupInfo, 
                out lpProcessInformation);

            if (result)
            {
                btnLaunch.Enabled = false;
                btnLaunch.Text = "Injecting into Borderlands 2...";

                this.InjectorThread.Start();

                Win32.CloseHandle(lpProcessInformation.hProcess);
                Win32.CloseHandle(lpProcessInformation.hThread);
            }
            else
            {
                MessageBox.Show("Failed to launch Borderlands 2. Error Code = " + Marshal.GetLastWin32Error(), "Failed to Launch", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void frmLauncher_Load(object sender, EventArgs e)
        {
            txtGamePath.Text = GetAbsoluteGamePath();
        }
    }
}
