using Microsoft.Win32;
using System;
using System.Diagnostics;
using System.IO;
using System.Windows.Forms;

namespace Launcher
{
    public partial class frmLauncher : Form
    {
        public frmLauncher()
        {
            InitializeComponent();
        }

        private string GetStartPath()
        {
            if (txtGamePath.TextLength > 0)
            {
                return Path.GetDirectoryName(txtGamePath.Text);
            }

            RegistryKey steamAppKey = Registry.LocalMachine.OpenSubKey(@"\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 49520");
            if (steamAppKey != null)
            {
                string installDir = (string)steamAppKey.GetValue("InstallLocation");
                if (!string.IsNullOrEmpty(installDir))
                {
                    return installDir;
                }
            }

            RegistryKey steamKey = Registry.CurrentUser.OpenSubKey("Software\\Valve\\Steam");
            if (steamKey != null)
            {
                string steamPath = (string)steamKey.GetValue("SteamPath");
                if (!string.IsNullOrEmpty(steamPath))
                {
                    string bl2Path = Path.GetFullPath(Path.Combine(steamPath, "steamapps", "common", "Borderlands2"));
                    if (Directory.Exists(bl2Path))
                    {
                        return bl2Path;
                    }
                }
            }
            return string.Empty;
        }

        private void btnBrowse_Click(object sender, EventArgs e)
        {
            OpenFileDialog openFileDialog = new OpenFileDialog();
            openFileDialog.InitialDirectory = this.GetStartPath();
            openFileDialog.Filter = "Borderlands 2 (*.exe)|*.exe";
            DialogResult result = openFileDialog.ShowDialog();
            if (result == DialogResult.OK)
            {
                txtGamePath.Text = openFileDialog.FileName;
                txtGamePath.ScrollToCaret();
            }
        }

        private void btnLaunch_Click(object sender, EventArgs e)
        {
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

            string gameDir = Path.GetDirectoryName(gamePath);

            Environment.SetEnvironmentVariable("SteamGameId", "49520");
            Environment.SetEnvironmentVariable("SteamAppId", "49520");

            WinAPI.STARTUPINFO lpStartupInfo = new WinAPI.STARTUPINFO();
            WinAPI.PROCESS_INFORMATION lpProcessInformation = new WinAPI.PROCESS_INFORMATION();

            if (WinAPI.CreateProcess(null, string.Format("{0} -nolauncher", gamePath), IntPtr.Zero, IntPtr.Zero, false, (uint)WinAPI.CreateProcessFlags.CREATE_SUSPENDED, IntPtr.Zero, gameDir, ref lpStartupInfo, out lpProcessInformation))
            {
                btnBrowse.Enabled = false;
                btnBrowse.Text = "Waiting for Borderlands 2 to launch...";

                WinAPI.CloseHandle(lpProcessInformation.hProcess);
                WinAPI.CloseHandle(lpProcessInformation.hThread);

                // Todo: Injection code lawl
            }
        }
    }
}
