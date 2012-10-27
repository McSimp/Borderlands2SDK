#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include "BL2SDK/BL2SDK.h"
#include "Logging/Logging.h"
#include "Detours/DetourManager.h"
#include "Commands/ConCmdManager.h"
#include "Commands/ConCommand.h"
#include "LuaInterface/LuaInterface.h"
#include "BL2SDK/Settings.h"
#include "BL2SDK/CrashRptHelper.h"
#include "BL2SDK/Util.h"

// TODO: Get these out of here
CON_COMMAND(CrashMe)
{
	Logging::Log("Thread: %i\n", GetCurrentThreadId());
	// Define the infinite loop where some processing will be done 
	for(;;)
	{
		// There is a hidden error somewhere inside of the loop...
		int* p = NULL;
		*p = 13; // This results in Access Violation
	}  
}

CON_COMMAND(PrintSDKVersion)
{
	Logging::Log("BL2 SDK Version %s\n", BL2SDK::Version.c_str());
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

// This function is used to ensure that everything gets called in the game thread once the game itself has loaded
bool GameReady(UObject* pCaller, UFunction* pFunction, void* pParms, void* pResult) 
{
	Logging::Log("[GameReady] Thread: %i\n", GetCurrentThreadId());
	
	CrashRptHelper::Initialize();

	Logging::InitializeExtern();
	Logging::InitializeGameConsole();
	Logging::PrintLogHeader();
	
	LuaInterface::Initialize();

	ConCmdManager::Initialize();

	BL2SDK::RemoveHook(pFunction);
	return true;
}

DWORD WINAPI onAttach(LPVOID lpParameter)
{	
	if(Settings::Initialize() != ERROR_SUCCESS)
	{
		Util::Popup(L"SDK Error", L"Could not locate settings in registry. Did you use the Launcher?");
		return 0;
	}

	Logging::InitializeFile(Settings::GetLogFilePath());
	Logging::Log("[Internal] Injecting SDK...\n");

	// Figure out GObjects and GNames
	if(!BL2SDK::Initialize())
	{
		// This usually wouldn't run because CrashRpt should handle things.
		// If CrashRpt doesn't install properly for some reason, this will have to do.
		Util::Popup(L"SDK ERROR", L"An error occurred while loading the SDK. Please check the logfile for details.");	
		return 0;
	}

	BL2SDK::RegisterHook("Function WillowGame.WillowGameInfo.InitGame", &GameReady);	
	return 0;
}

BOOL WINAPI DllMain(HMODULE hModule, DWORD dwReason, LPVOID lpReserved)
{
	switch(dwReason)
	{
		case DLL_PROCESS_ATTACH:
			DisableThreadLibraryCalls(hModule);	
			CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)onAttach, NULL, 0, NULL);
			return true;
		break;

		case DLL_PROCESS_DETACH:
			// TODO: Graceful detach
			Logging::Cleanup();
			CrashRptHelper::Cleanup();
			return true;
		break;
	}
}