#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include "BL2SDK/BL2SDK.h"
#include "Logging/Logging.h"
#include "Commands/ConCommand.h"
#include "BL2SDK/CrashRptHelper.h"
#include "BL2SDK/Util.h"
#include "BL2SDK/Exceptions.h"

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

CON_COMMAND(GetLocalPlayer)
{
	AActor* pc = UObject::FindObject<AActor>("WillowPlayerController TheWorld.PersistentLevel.WillowPlayerController");
	Logging::Log("pc = 0x%X\n", pc);
}

CON_COMMAND(PrintSDKVersion)
{
	Logging::Log("BL2 SDK Version %s\n", BL2SDK::Version.c_str());
}
/*
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
*/

CON_COMMAND(DumpObj)
{
	Logging::Log("=== OBJECT DUMP ===\n");
	for(int i = 0; i < UObject::GObjObjects()->Count; i++) 
	{ 
		UObject* Object = UObject::GObjObjects()->Data[i];
		if(Object)
		{
			Logging::Log("%d | 0x%X | %s\n", i, Object, Object->GetFullName());
		}
		else
		{
			Logging::Log("[DEBUGLOG] Got a null UObject at idx %d?\n", i);
		}
	} 
	Logging::Log("=== END OBJECT DUMP ===\n");
}

CON_COMMAND(CountNullObj)
{
	Logging::Log("=== OBJECT DUMP ===\n");
	int count = 0;
	for(int i = 0; i < UObject::GObjObjects()->Count; i++) 
	{ 
		UObject* Object = UObject::GObjObjects()->Data[i];
		if(!Object)
		{
			Logging::Log("%d\n", i);
			count++;
		}
	} 
	Logging::Log("Count Null = %d\n", count);
	Logging::Log("=== END OBJECT DUMP ===\n");
}

CON_COMMAND(Derp)
{
	Logging::Log("=== OBJECT DUMP ===\n");
	Logging::Log("%40s | %10s\n", "Name", "ArrayDim");
	for(int i = 0; i < UObject::GObjObjects()->Count; i++) 
	{ 
		UObject* Object = UObject::GObjObjects()->Data[i];
		//Logging::Log("%d | 0x%X | %s\n", i, Object, Object->GetFullName()); 
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

extern "C" __declspec(dllexport) DWORD InitializeSDK(LPVOID lpParameter)
{
	try
	{
		BL2SDK::Initialize();
	}
	catch(FatalSDKException &ex)
	{
		Util::Popup(L"SDK Error", Util::Widen(ex.what()));
		CrashRptHelper::SoftCrash();
	}

	return 0;
}

BOOL WINAPI DllMain(HMODULE hModule, DWORD dwReason, LPVOID lpReserved)
{
	switch(dwReason)
	{
		case DLL_PROCESS_ATTACH:
			DisableThreadLibraryCalls(hModule);
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