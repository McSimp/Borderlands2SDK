#define WIN32_LEAN_AND_MEAN
#define STEAM_VERSION
#include <Windows.h>
#include "BL2SDK/BL2SDK.h"
#include "Logging/Logging.h"
#include "Detours/DetourManager.h"
#include "Commands/ConCmdManager.h"

void onAttach()
{	
	Logging::InitializeExtern();
	Logging::InitializeFile("pelog.txt");
	Logging::Log("[INTERNAL] Injecting SDK...\n");

	// Figure out GObjects and GNames
	if(!BL2SDK::Initialize())
	{
		MessageBox(NULL, L"An error occurred while loading the SDK. Please check the logfile for details.", L"SDK ERROR", MB_OK);	
		return;
	}

	Logging::InitializeGameConsole();
	Logging::PrintLogHeader();

	ConCmdManager::Initialize();
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