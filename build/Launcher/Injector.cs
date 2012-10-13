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
        public static void Inject(string libPath, Process proc)
        {
            // Check if DLL is present
            if (!File.Exists(libPath))
            {
                throw new FileNotFoundException("Injectee DLL not found", libPath);
            }

            // Get a handle on LoadLibraryW so we can call it in the game process later
            IntPtr hKernel32 = Win32.GetModuleHandle("kernel32.dll");
            IntPtr hLoadLib = Win32.GetProcAddress(hKernel32, "LoadLibraryW");
            if (hKernel32 == IntPtr.Zero || hLoadLib == IntPtr.Zero)
            {
                throw new Win32Exception(Marshal.GetLastWin32Error(), "Failed to get handle to LoadLibraryW");
            }

            // Get a native handle to the process
            Win32.ProcessAccessFlags access = 
                  Win32.ProcessAccessFlags.CreateThread
                | Win32.ProcessAccessFlags.VMOperation
                | Win32.ProcessAccessFlags.VMRead
                | Win32.ProcessAccessFlags.VMWrite
                | Win32.ProcessAccessFlags.QueryInformation;

            IntPtr hProcess = Win32.OpenProcess(access, false, proc.Id);
            if (hProcess == IntPtr.Zero)
            {
                throw new Win32Exception(Marshal.GetLastWin32Error(), "Failed to get handle to game process");
            }

            // Create unicode version of the path to the DLL
            byte[] unicodePath = Encoding.Unicode.GetBytes(libPath);

            // Allocate memory in the remote process for the path
            using (RemoteMemory remoteMem = new RemoteMemory(hProcess, (uint)unicodePath.Length))
            {
                // Write the path to the memory
                remoteMem.WriteMemory(unicodePath);

                // Execute LoadLibraryW on the path in the remote process
                IntPtr hThread = Win32.CreateRemoteThread(
                    hProcess,
                    IntPtr.Zero,
                    0U,
                    hLoadLib,
                    remoteMem.Address,
                    0U,
                    IntPtr.Zero);
                if (hThread == IntPtr.Zero)
                {
                    Win32.CloseHandle(hProcess);
                    throw new Win32Exception(Marshal.GetLastWin32Error(), "Failed to execute remote LoadLibraryW");
                }

                // Wait for the thread to do its thing, error out if it doesn't manage to
                if (Win32.WaitForSingleObject(hThread, (uint)Win32.ThreadWaitValue.Infinite) != (uint)Win32.ThreadWaitValue.Object0)
                {
                    Win32.CloseHandle(hThread);
                    Win32.CloseHandle(hProcess);
                    throw new Win32Exception(Marshal.GetLastWin32Error(), "Failed to wait for remote thread");
                }

                // Get the result of LoadLibraryW - throw exception if it didn't appear to load
                IntPtr hInjectedDLL;
                if (!Win32.GetExitCodeThread(hThread, out hInjectedDLL) || hInjectedDLL == IntPtr.Zero)
                {
                    Win32.CloseHandle(hThread);
                    Win32.CloseHandle(hProcess);
                }
            }

            // Looks like we made it!
        }
    }
}
