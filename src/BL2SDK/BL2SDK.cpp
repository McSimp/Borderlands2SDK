#include "BL2SDK/BL2SDK.h"
#include "BL2SDK/CSimpleDetour.h"
#include "Logging/Logging.h"
#include "BL2SDK/CSigScan.h"
#include "BL2SDK/CrashRptHelper.h"
#include "BL2SDK/EngineHooks.h"
#include "BL2SDK/Settings.h"
#include "BL2SDK/Util.h"
#include "Commands/ConCmdManager.h"
#include "GUI/D3D9Hook.h"
#include "LuaInterface/LuaManager.h"

namespace BL2SDK
{
	bool										bInjectedCallNext = false;
	bool										bLogAllEvents = false;

	unsigned long								pGObjects;
	unsigned long								pGNames;
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
		return pGObjects;
	}

	unsigned long GNames()
	{
		return pGNames;
	}

	int UnrealExceptionHandler(unsigned int code, struct _EXCEPTION_POINTERS *ep)
	{
		if(CrashRptHelper::GenerateReport(code, ep))
		{
			Util::CloseGame();
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
		unsigned char* addrGObjects = (unsigned char*)sigscan.Scan((unsigned char*)GObjects_Pattern, GObjects_Mask);
		if(addrGObjects == NULL)
		{
			Logging::Log("[Internal] ERROR: Code = GOBJSIGFAIL. Failed to sigscan for GObjects.\n");	
			return false;
		}

		pGObjects = *(unsigned long*)addrGObjects;
		Logging::Log("[Internal] GObjects = 0x%X\n", pGObjects);

		// Sigscan for GNames
		unsigned char* addrGNames = (unsigned char*)sigscan.Scan((unsigned char*)GNames_Pattern, GNames_Mask);
		if(addrGNames == NULL)
		{
			Logging::Log("[Internal] ERROR: Code = GNAMESSIGFAIL. Failed to sigscan for GNames.\n");	
			return false;
		}

		pGNames = *(unsigned long*)addrGNames;
		Logging::Log("[Internal] GNames = 0x%X\n", pGNames);

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

	// This function is used to ensure that everything gets called in the game thread once the game itself has loaded
	bool GameReady(UObject* pCaller, UFunction* pFunction, void* pParms, void* pResult) 
	{
		Logging::Log("[GameReady] Thread: %i\n", GetCurrentThreadId());
	
		Logging::InitializeExtern();
		//Logging::InitializeGameConsole();
		Logging::PrintLogHeader();
	
		LuaManager::Initialize();

		ConCmdManager::Initialize();

		EngineHooks::RemoveStaticHook(pFunction, "StartupSDK");
		return true;
	}

	bool Initialize()
	{
		if(Settings::Initialize() != ERROR_SUCCESS)
		{
			// Can't use Crashrpt because it won't be started. This error shouldn't
			// ever really happen though.
			Util::Popup(L"SDK Error", L"Could not locate settings in registry. Did you use the Launcher?");
			return false;
		}

		Logging::InitializeFile(Settings::GetLogFilePath());
		Logging::Log("[Internal] Launching SDK...\n");

		CrashRptHelper::Initialize();

		if(!HookGame())
		{
			// Close the game and get the crashrpt dialog to come up in the hope that
			// the user will tell us what went wrong.
			Logging::Log("[Internal] Failed to hook game, terminating process\n");
			CrashRptHelper::SoftCrash();
			return false;
		}

		if(!D3D9Hook::Initialize())
		{
			Logging::Log("[DirectX Hooking] Failed to hook DirectX, terminating process\n");
			return false;
		}

		EngineHooks::Register("Function WillowGame.WillowGameInfo.InitGame", "StartupSDK", &GameReady);	

		return true;
	}
}