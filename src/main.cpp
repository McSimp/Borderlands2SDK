#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include "BL2SDK/BL2SDK.h"
#include "Logging/Logging.h"
#include "Detours/DetourManager.h"
#include "Commands/ConCmdManager.h"

void onAttach()
{	
	if(!DetourManager::AttachProcessEvent())
	{
		MessageBox(NULL, L"Failed to attach to ProcessEvent. This is likely caused by the Mod SDK being outdated or attempting to use it with a cracked version of the game.", L"SDK ERROR", MB_OK);
		return;
	}

	Logging::InitializeExtern();
	Logging::InitializeFile("pelog.txt");
	Logging::InitializeGameConsole();
	Logging::PrintLogHeader();

	Logging::Log("Detour attached\n");
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