#include "BL2SDK/BL2SDK.h"
#include "BL2SDK/CSimpleDetour.h"
#include "Logging/Logging.h"
#include "BL2SDK/CSigScan.h"
#include "BL2SDK/CrashRptHelper.h"
#include "BL2SDK/EngineHooks.h"

namespace BL2SDK
{
	bool										bInjectedCallNext = false;
	bool										bLogAllEvents = false;

	unsigned long								addrGObjects;
	unsigned long								addrGNames;
	tProcessEvent								pProcessEvent;

	void __stdcall hkProcessEvent(UObject* pCaller, UFunction* pFunction, void* pParms, void* pResult)
	{
		// Save the registers
		_asm pushad;

		if(bInjectedCallNext)
		{
			bInjectedCallNext = false;
			// Sooooo tempted to use a goto here
			_asm popad;
			pProcessEvent(pCaller, pFunction, pParms, pResult);
			return;
		}

		if(bLogAllEvents)
		{
			std::string CallerName = pCaller->GetFullName();
			std::string FunctionName = pFunction->GetFullName();

			Logging::Log("===== ProcessEvent called =====\n");
			Logging::Log("pCaller Name = %s\n", CallerName.c_str());
			Logging::Log("pFunction Name = %s\n", FunctionName.c_str());
		}
		
		if(!EngineHooks::ProcessHooks(pCaller, pFunction, pParms, pResult))
		{
			// The engine hook manager told us not to pass this function to the engine
			_asm popad;
			return;
		}
		
		_asm popad;
		pProcessEvent(pCaller, pFunction, pParms, pResult);
		return;
	}

	void __declspec(naked) hkRawProcessEvent()
	{
		__asm
		{
			push ebp
			mov ebp, esp
			push [ebp+16]
			push [ebp+12]
			push [ebp+8]
			push ecx
			call hkProcessEvent
			pop ebp
			retn 12
		}
	}

	void InjectedCallNext()
	{
		bInjectedCallNext = true;
	}

	void LogAllEvents(bool enabled)
	{
		bLogAllEvents = enabled;
	}	

	unsigned long GObjects()
	{
		return addrGObjects;
	}

	unsigned long GNames()
	{
		return addrGNames;
	}

	int UnrealExceptionHandler(unsigned int code, struct _EXCEPTION_POINTERS *ep)
	{
		if(CrashRptHelper::GenerateReport(code, ep))
		{
			TerminateProcess(GetCurrentProcess(), 1);
		}
		else
		{
			// TODO: Maybe have it call the original Engine func here
		}

		return EXCEPTION_EXECUTE_HANDLER;
	}

	// TODO: Make less shit
	bool HookGame()
	{
		CSigScan sigscan(L"Borderlands2.exe");

		if(!sigscan.IsReady())
		{
			Logging::Log("[Internal] ERROR: Code = SDKMEMBASEERR. Failed to find base of Borderlands2.exe\n");
			return false;
		}

		// Sigscan for GOBjects
		unsigned char* pGObjects = (unsigned char*)sigscan.Scan((unsigned char*)GObjects_Pattern, GObjects_Mask);
		if(pGObjects == NULL)
		{
			Logging::Log("[Internal] ERROR: Code = GOBJSIGFAIL. Failed to sigscan for GObjects.\n");	
			return false;
		}

		pGObjects += MOV_OP_OFFSET;
		addrGObjects = *(unsigned long*)pGObjects;
		Logging::Log("[Internal] GObjects = 0x%X\n", addrGObjects);

		// Sigscan for GNames
		unsigned char* pGNames = (unsigned char*)sigscan.Scan((unsigned char*)GNames_Pattern, GNames_Mask);
		if(pGNames == NULL)
		{
			Logging::Log("[Internal] ERROR: Code = GNAMESSIGFAIL. Failed to sigscan for GNames.\n");	
			return false;
		}

		pGNames += MOV_OP_OFFSET;
		addrGNames = *(unsigned long*)pGNames;
		Logging::Log("[Internal] GNames = 0x%X\n", addrGNames);

		// Sigscan for UObject::ProcessEvent which will be used for pretty much everything
		void* addrProcEvent = sigscan.Scan((unsigned char*)ProcessEvent_Pattern, ProcessEvent_Mask);
		if(addrProcEvent == NULL)
		{
			Logging::Log("[Internal] ERROR: Code = PROCEVENTSIGFAIL. Failed to sigscan for UObject::ProcessEvent().\n");	
			return false;
		}

		pProcessEvent = reinterpret_cast<tProcessEvent>(addrProcEvent);
		Logging::Log("[Internal] UObject::ProcessEvent() = 0x%X\n", pProcessEvent);

		// Detour UObject::ProcessEvent()
		SETUP_SIMPLE_DETOUR(detProcessEvent, pProcessEvent, hkRawProcessEvent);
		if(!detProcessEvent.Attach())
		{
			Logging::Log("[Internal] ERROR: Code = PROCEVENTDETOURFAIL. Failed to attach to UObject::ProcessEvent().\n");
			return false;
		}

		// Sigscan for Unreal exception handler
		void* addrUnrealEH = sigscan.Scan((unsigned char*)CrashHandler_Pattern, CrashHandler_Mask);
		if(addrUnrealEH == NULL)
		{
			Logging::Log("[Internal] ERROR: Code = CRASHHANDLERSIGFAIL. Failed to sigscan for Unreal Exception Handler.\n");	
			return false;
		}

		Logging::Log("[Internal] Unreal Crash handler = 0x%X\n", addrUnrealEH);

		// Detour Unreal exception handler
		SETUP_SIMPLE_DETOUR(detUnrealEH, addrUnrealEH, UnrealExceptionHandler);
		if(!detUnrealEH.Attach())
		{
			Logging::Log("[Internal] ERROR: Code = CRASHHANDLERDETOURFAIL. Failed to attach to Unreal Exception Handler.\n");
			return false;
		}

		return true;
	}

	bool Initialize()
	{
		if(!HookGame())
		{
			// Close the game and get the crashrpt dialog to come up in the hope that
			// the user will tell us what went wrong.
			CrashRptHelper::SoftCrash();
			return false;
		}

		return true;
	}
}