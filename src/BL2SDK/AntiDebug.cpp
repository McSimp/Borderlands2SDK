#include "BL2SDK/BL2SDK.h"
#include "BL2SDK/CSimpleDetour.h"
#include "Logging/Logging.h"

#include <winternl.h>
#define STATUS_SUCCESS ((NTSTATUS)0x00000000L)
#define STATUS_PORT_NOT_SET ((NTSTATUS)0xC0000353L)

namespace BL2SDK
{
	typedef PVOID (WINAPI* tAVEH) (ULONG, PVECTORED_EXCEPTION_HANDLER);
	tAVEH pAddVectoredExceptionHandler = AddVectoredExceptionHandler;

	PVOID WINAPI hkAVEH(ULONG FirstHandler, PVECTORED_EXCEPTION_HANDLER VectoredHandler)
	{
		Logging::LogF("[AntiDebug] AddVectoredExceptionHandler called (%d, 0x%X)\n", FirstHandler, VectoredHandler);
		return NULL;
	}

	typedef NTSTATUS (WINAPI* tNtSIT) (HANDLE, THREAD_INFORMATION_CLASS, PVOID, ULONG);
	tNtSIT pNtSetInformationThread = NULL;

	NTSTATUS NTAPI hkNtSetInformationThread(
		__in HANDLE ThreadHandle, 
		__in THREAD_INFORMATION_CLASS ThreadInformationClass,
		__in PVOID ThreadInformation,
		__in ULONG ThreadInformationLength)
	{
		if(ThreadInformationClass == 17) // ThreadHideFromDebugger
		{
			Logging::Log("[AntiDebug] NtSetInformationThread called with ThreadHideFromDebugger\n");
			return STATUS_SUCCESS;
		}

		return pNtSetInformationThread(ThreadHandle, ThreadInformationClass, ThreadInformation, ThreadInformationLength);
	}

	typedef NTSTATUS (WINAPI* tNtQIP) (HANDLE, PROCESSINFOCLASS, PVOID, ULONG, PULONG);
	tNtQIP pNtQueryInformationProcess = NULL;

	NTSTATUS WINAPI hkNtQueryInformationProcess(
		__in HANDLE ProcessHandle,
		__in PROCESSINFOCLASS ProcessInformationClass, 
		__out PVOID ProcessInformation,
		__in ULONG ProcessInformationLength,
		__out_opt PULONG ReturnLength)
	{
		if(ProcessInformationClass == 30) // ProcessDebugObjectHandle
		{
			return STATUS_PORT_NOT_SET;
		}

		return pNtQueryInformationProcess(ProcessHandle, ProcessInformationClass, ProcessInformation, ProcessInformationLength, ReturnLength);
	}

	void HookAntiDebug()
	{
		SETUP_SIMPLE_DETOUR(detAVEH, pAddVectoredExceptionHandler, hkAVEH);
		detAVEH.Attach();
		Logging::Log("[AntiDebug] Hook added for AddVectoredExceptionHandler\n");

		pNtSetInformationThread = (tNtSIT)GetProcAddress(GetModuleHandle(L"ntdll.dll"), "NtSetInformationThread"); // TODO: Error handling
		SETUP_SIMPLE_DETOUR(detNtSIT, pNtSetInformationThread, hkNtSetInformationThread);
		detNtSIT.Attach();
		Logging::Log("[AntiDebug] Hook added for NtSetInformationThread\n");

		pNtQueryInformationProcess = (tNtQIP)GetProcAddress(GetModuleHandle(L"ntdll.dll"), "NtQueryInformationProcess"); // TODO: Error handling
		SETUP_SIMPLE_DETOUR(detNtQIP, pNtQueryInformationProcess, hkNtQueryInformationProcess);
		detNtQIP.Attach();
		Logging::Log("[AntiDebug] Hook added for NtQueryInformationProcess\n");
	}

	// TODO: Remove detours on close
}