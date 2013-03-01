using System;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;

namespace Launcher
{
    public class RemoteMemory : IDisposable
    {
        private readonly IntPtr pMemory = IntPtr.Zero;
        private readonly IntPtr hProcess;

        public IntPtr Address
        {
            get
            {
                return this.pMemory;
            }
        }

        public RemoteMemory(IntPtr hProcess, uint size)
        {
            this.hProcess = hProcess;
            this.pMemory = Win32.VirtualAllocEx(
                hProcess,
                IntPtr.Zero,
                size,
                Win32.AllocationType.Commit | Win32.AllocationType.Reserve,
                Win32.MemoryProtection.ReadWrite);

            if (this.pMemory == IntPtr.Zero)
            {
                Win32.CloseHandle(hProcess);
                throw new Win32Exception(Marshal.GetLastWin32Error(), "Failed to allocate memory in remote process");
            }
        }

        public void WriteMemory(byte[] pBuffer)
        {
            UIntPtr lpNumberOfBytesWritten;

            bool result = Win32.WriteProcessMemory(
                this.hProcess,
                this.pMemory,
                pBuffer,
                (uint)pBuffer.Length,
                out lpNumberOfBytesWritten);

            if (!result || lpNumberOfBytesWritten != (UIntPtr)(pBuffer.Length))
            {
                Win32.CloseHandle(hProcess);
                throw new Win32Exception(Marshal.GetLastWin32Error(), "Failed to write memory in remote process");
            }
        }

        public void Dispose()
        {
            if (this.pMemory == IntPtr.Zero)
            {
                return;
            }

            Win32.VirtualFreeEx(this.hProcess, this.pMemory, 0, Win32.FreeType.Release);
        }
    }

    public static class Injector
    {
        public static IntPtr CallFunction(Process proc, IntPtr hFunction, IntPtr pFuncArg = default(IntPtr))
        {
            // Get a native handle to the process
            Win32.ProcessAccessFlags access =
                  Win32.ProcessAccessFlags.CreateThread
                | Win32.ProcessAccessFlags.VMOperation
                | Win32.ProcessAccessFlags.VMRead
                | Win32.ProcessAccessFlags.VMWrite
                | Win32.ProcessAccessFlags.QueryInformation;

            IntPtr hProcess = Win32.OpenProcess(access, false, proc.Id);
            if(hProcess == IntPtr.Zero)
            {
                throw new Win32Exception(Marshal.GetLastWin32Error(), "Failed to get handle to process");
            }

            IntPtr result;
            try
            {
                result = CallFunction(hProcess, hFunction, pFuncArg);
            }
            catch(Exception e)
            {
                throw e;
            }
            finally
            {
                Win32.CloseHandle(hProcess);
            }

            return result;
        }

        public static IntPtr CallFunction(IntPtr hProcess, IntPtr hFunction, IntPtr pFuncArg = default(IntPtr))
        {
            IntPtr hThread = Win32.CreateRemoteThread(
                    hProcess,
                    IntPtr.Zero,
                    0U,
                    hFunction,
                    pFuncArg,
                    0U,
                    IntPtr.Zero);
            if(hThread == IntPtr.Zero)
            {
                throw new Win32Exception(Marshal.GetLastWin32Error(), "Failed to execute remote function");
            }

            // Wait for the thread to do its thing, error out if it doesn't manage to
            if(Win32.WaitForSingleObject(hThread, (uint)Win32.ThreadWaitValue.Infinite) != (uint)Win32.ThreadWaitValue.Object0)
            {
                Win32.CloseHandle(hThread);
                throw new Win32Exception(Marshal.GetLastWin32Error(), "Failed to wait for remote thread");
            }

            // Get the result of the function call - throw exception if it didn't appear to load
            IntPtr exitCode;
            if(!Win32.GetExitCodeThread(hThread, out exitCode))
            {
                Win32.CloseHandle(hThread);
                throw new Win32Exception(Marshal.GetLastWin32Error(), "Failed to get exit code from thread");
            }

            return exitCode;
        }

        public static void Inject(string libPath, Process proc)
        {
            // Check if DLL is present
            if (!File.Exists(libPath))
            {
                throw new FileNotFoundException("Injectee DLL not found", libPath);
            }

            // Get a handle on LoadLibraryW so we can call it in the game process later
            IntPtr hKernel32 = Win32.GetModuleHandle("kernel32.dll");
            if(hKernel32 == IntPtr.Zero )
            {
                throw new Win32Exception(Marshal.GetLastWin32Error(), "Failed to get handle to kernel32.dll");
            }

            IntPtr hLoadLib = Win32.GetProcAddress(hKernel32, "LoadLibraryW");
            if(hLoadLib == IntPtr.Zero)
            {
                throw new Win32Exception(Marshal.GetLastWin32Error(), "Failed to get handle to kernel32.dll functions");
            }

            // Create unicode version of the path to the DLL
            byte[] unicodePath = Encoding.Unicode.GetBytes(libPath);

            // Get a native handle to the process
            Win32.ProcessAccessFlags access =
                  Win32.ProcessAccessFlags.CreateThread
                | Win32.ProcessAccessFlags.VMOperation
                | Win32.ProcessAccessFlags.VMRead
                | Win32.ProcessAccessFlags.VMWrite
                | Win32.ProcessAccessFlags.QueryInformation;

            IntPtr hProcess = Win32.OpenProcess(access, false, proc.Id);
            if(hProcess == IntPtr.Zero)
            {
                throw new Win32Exception(Marshal.GetLastWin32Error(), "Failed to get handle to process");
            }

            try
            {
                // Allocate memory in the remote process for the path and call LoadLibraryW on it
                IntPtr hRemoteSDKDLL;
                using(RemoteMemory remoteMem = new RemoteMemory(hProcess, (uint)unicodePath.Length))
                {
                    // Write the path to the memory
                    remoteMem.WriteMemory(unicodePath);

                    hRemoteSDKDLL = CallFunction(hProcess, hLoadLib, remoteMem.Address);
                    if(hRemoteSDKDLL == IntPtr.Zero)
                    {
                        throw new Win32Exception(Marshal.GetLastWin32Error(), "Failed to load library");
                    }
                }

                // I hate this. I supppose this is what I get for doing this in C#.
                // Load the SDK DLL into this process to get the location of the initialize function.
                IntPtr hLocalSDKDLL = Win32.LoadLibraryEx("BL2SDKDLL.dll", IntPtr.Zero, Win32.LoadLibraryExFlags.DontResolveDLLReferences);
                if(hLocalSDKDLL == IntPtr.Zero)
                {
                    throw new Win32Exception(Marshal.GetLastWin32Error(), "Failed to load library");
                }

                IntPtr hLocalInit = Win32.GetProcAddress(hLocalSDKDLL, "InitializeSDK");
                if(hLocalInit == IntPtr.Zero)
                {
                    throw new Win32Exception(Marshal.GetLastWin32Error(), "Failed to find function in SDK DLL");
                }

                ProcessModule modFound = null;
                foreach(ProcessModule mod in proc.Modules)
                {
                    if(mod.ModuleName == "BL2SDKDLL.dll")
                    {
                        modFound = mod;
                        break;
                    }
                }

                IntPtr remoteInit = new IntPtr(modFound.BaseAddress.ToInt32() + (hLocalInit.ToInt32() - hLocalSDKDLL.ToInt32()));
                CallFunction(hProcess, remoteInit, IntPtr.Zero);
            }
            finally
            {
                Win32.CloseHandle(hProcess);
            }

            // Looks like we made it!
        }
    }
}
