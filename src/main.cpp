#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include "BL2SDK/BL2SDK.h"
#include "Logging/Logging.h"
#include "Commands/ConCommand.h"
#include "BL2SDK/CrashRptHelper.h"
#include "BL2SDK/Util.h"

// TODO: Get these out of here
CON_COMMAND(CrashMe)
{
	Logging::Log("Thread: %i\n", GetCurrentThreadId());
	abort();
	/*
	// Define the infinite loop where some processing will be done 
	for(;;)
	{
		// There is a hidden error somewhere inside of the loop...
		int* p = NULL;
		*p = 13; // This results in Access Violation
	}
	*/
	
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

CON_COMMAND(Derp)
{
	Logging::Log("=== OBJECT DUMP ===\n");
	Logging::Log("%40s | %10s\n", "Name", "ArrayDim");
	for(int i = 0; i < UObject::GObjObjects()->Count; i++) 
	{ 
		UObject* Object = UObject::GObjObjects()->Data[i];
		if(Object->IsA(UProperty::StaticClass()))
		{
			UProperty* prop = (UProperty*)Object;
			if(prop->ArrayDim > 1 || prop->IsA(UArrayProperty::StaticClass()))
			{
				Logging::Log(" %40s | %10i | %10i\n", prop->Name.GetName(), prop->ArrayDim, prop->IsA(UArrayProperty::StaticClass()));
			}
		}
		
	} 
	Logging::Log("=== END OBJECT DUMP ===\n");
}


DWORD WINAPI onAttach(LPVOID lpParameter)
{	
	if(!BL2SDK::Initialize())
	{
		// This usually wouldn't run because CrashRpt should handle things.
		// If CrashRpt doesn't install properly for some reason, this will have to do.
		Util::Popup(L"SDK Error", L"An error occurred initializing the BL2 SDK, please check the logfile for details.");
		Util::CloseGame();
	}

	return 0;
}

BOOL WINAPI DllMain(HMODULE hModule, DWORD dwReason, LPVOID lpReserved)
{
	switch(dwReason)
	{
		case DLL_PROCESS_ATTACH:
			DisableThreadLibraryCalls(hModule);	
			CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)onAttach, NULL, 0, NULL);
			return TRUE;
		break;

		case DLL_PROCESS_DETACH:
			// TODO: Graceful detach
			Logging::Cleanup();
			CrashRptHelper::Cleanup();
			return FALSE;
		break;
	}
}