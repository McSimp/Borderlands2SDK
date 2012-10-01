#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include "BL2SDK/BL2SDK.h"
#include "Logging/Logging.h"
#include "Detours/DetourManager.h"

#pragma comment (lib, "detours.lib")

void onAttach()
{	
	Logging::InitializeExtern();
	Logging::InitializeFile("pelog.txt");
	Logging::PrintLogHeader();

	BL2SDK::LogAllEvents(true);

	//DetourManager::ProcessEvent_Detour.Attach();
	DetourManager::AttachProcessEvent();
	Logging::Log("Detour attached\n");
}

BOOL WINAPI DllMain(HMODULE hModule, DWORD dwReason, LPVOID lpReserved)
{
	switch (dwReason)
	{
		case DLL_PROCESS_ATTACH:
			DisableThreadLibraryCalls (hModule);
			CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE) onAttach, NULL, 0, NULL);
			return true;
		break;

		case DLL_PROCESS_DETACH:
			// TODO: Graceful detach
			return true;
		break;
	}
}