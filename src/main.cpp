#define WIN32_LEAN_AND_MEAN
#define STEAM_VERSION
#include <Windows.h>
#include "BL2SDK/BL2SDK.h"
#include "Logging/Logging.h"
#include "Detours/DetourManager.h"
#include "Commands/ConCmdManager.h"
#include "Commands/ConCommand.h"
#include "LuaInterface/LuaInterface.h"

CON_COMMAND(PrintSDKVersion)
{	
	Logging::Log("BL2 SDK Version %s\n", BL2_SDK_VER);
}

CON_COMMAND(SetDNCycleRate)
{
	if(args.size() < 2)
	{
		Logging::Log("Bad arguments to command\n");
		return;
	}

	float rate = std::atof(args[1].c_str());
	UGlobalsDefinition* gd = UObject::FindObject<UGlobalsDefinition>("GlobalsDefinition GD_Globals.General.Globals");
	gd->DayNightCycleRate = rate;

	AWillowGameReplicationInfo* ri = UObject::FindObject<AWillowGameReplicationInfo>("WillowGameReplicationInfo TheWorld.PersistentLevel.WillowGameReplicationInfo");
	ri->DayNightCycleRate = rate;
	ri->DayNightCycleRateBaseValue = rate;

	UWillowSeqAct_DayNightCycle* seqact = UObject::FindObject<UWillowSeqAct_DayNightCycle>("WillowSeqAct_DayNightCycle PersistentLevel.Main_Sequence.WillowSeqAct_DayNightCycle");
	seqact->PlayRate = rate;

	Logging::Log("Day/Night cycle rate changed to %f\n", rate);
}

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
	
	//BL2SDK::LogAllEvents(true);

	LuaInterface::Initialize();

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