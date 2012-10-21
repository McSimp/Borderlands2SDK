#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include <tchar.h>
#include "BL2SDK/BL2SDK.h"
#include "Logging/Logging.h"
#include "Detours/DetourManager.h"
#include "Commands/ConCmdManager.h"
#include "Commands/ConCommand.h"
#include "LuaInterface/LuaInterface.h"
#include "BL2SDK/Settings.h"
#include "BL2SDK/CrashRptHelper.h"

// TODO: Get these out of here
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

// TODO: Util namespace?
void Popup(const std::wstring &strName, const std::wstring &strText)
{
	MessageBox(NULL, strText.c_str(), strName.c_str(), MB_OK | MB_ICONASTERISK);
}

bool GameReady(UObject* pCaller, UFunction* pFunction, void* pParms, void* pResult) 
{
	Logging::InitializeExtern();
	Logging::InitializeGameConsole();
	Logging::PrintLogHeader();
	
	LuaInterface::Initialize();

	ConCmdManager::Initialize();

	BL2SDK::RemoveHook(pFunction);
	return true;
}

void onAttach()
{	
	if(Settings::Initialize() != ERROR_SUCCESS)
	{
		Popup(L"SDK Error", L"Could not locate settings in registry. Did you use the Launcher?");
		return;
	}

	CrashRptHelper::Initialize();

	Logging::InitializeFile(Settings::GetLogFilePath());
	Logging::Log("[INTERNAL] Injecting SDK...\n");

	// Figure out GObjects and GNames
	if(!BL2SDK::Initialize())
	{
		Popup(L"SDK ERROR", L"An error occurred while loading the SDK. Please check the logfile for details.");	
		return;
	}

	BL2SDK::LogAllEvents(true);

	BL2SDK::RegisterHook("Function WillowGame.WillowGameInfo.InitGame", &GameReady);
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
			//CrashRptHelper::Cleanup();
			return true;
		break;
	}
}