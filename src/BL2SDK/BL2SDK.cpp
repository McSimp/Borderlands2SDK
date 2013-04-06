#include "BL2SDK/BL2SDK.h"
#include "BL2SDK/CSimpleDetour.h"
#include "BL2SDK/Logging.h"
#include "BL2SDK/CSigScan.h"
#include "BL2SDK/CrashRptHelper.h"
#include "BL2SDK/GameHooks.h"
#include "BL2SDK/Settings.h"
#include "BL2SDK/Util.h"
#include "Commands/ConCmdManager.h"
#include "GUI/D3D9Hook.h"
#include "LuaInterface/LuaManager.h"
#include "BL2SDK/Exceptions.h"
#include "BL2SDK/AntiDebug.h"
#include "GUI/GwenManager.h"

namespace BL2SDK
{
	bool										bInjectedCallNext = false;
	bool										bLogAllEvents = false;

	unsigned long								pGObjects;
	unsigned long								pGNames;
	unsigned long								pGObjHash;
	tProcessEvent								pProcessEvent;
	tCallFunction								pCallFunction;

	void __stdcall hkProcessEvent(UFunction* pFunction, void* pParms, void* pResult)
	{
		// Get "this"
		UObject* pCaller;
		_asm mov pCaller, ecx;

		if(bInjectedCallNext)
		{
			bInjectedCallNext = false;
			pProcessEvent(pCaller, pFunction, pParms, pResult);
			return;
		}

		if(bLogAllEvents)
		{
			std::string CallerName = pCaller->GetFullName();
			std::string FunctionName = pFunction->GetFullName();

			Logging::Log("===== ProcessEvent called =====\n");
			Logging::LogF("pCaller Name = %s\n", CallerName.c_str());
			Logging::LogF("pFunction Name = %s\n", FunctionName.c_str());
		}
		
		if(!GameHooks::ProcessEngineHooks(pCaller, pFunction, pParms, pResult))
		{
			// The engine hook manager told us not to pass this function to the engine
			return;
		}
		
		pProcessEvent(pCaller, pFunction, pParms, pResult);
	}

	void __stdcall hkCallFunction(FFrame& Stack, void* const Result, UFunction* Function)
	{
		// Get "this"
		UObject* pCaller;
		_asm mov pCaller, ecx;

		if((UObject*)Function == UObject::GObjObjects()->Data[68500])
		{
			_asm nop;
		}

		pCallFunction(pCaller, Stack, Result, Function);
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

	unsigned long addrProcessEvent()
	{
		return (unsigned long)pProcessEvent;
	}

	unsigned long GObjHash()
	{
		return pGObjHash;
	}

	unsigned long addrCallFunction()
	{
		return (unsigned long)pCallFunction;
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

	bool GetGameVersion(std::wstring& appVersion)
	{
		wchar_t* szFilename = L"Borderlands2.exe";

		// Allocate a block of memory for the version info
		DWORD dwDummy;
		DWORD dwSize = GetFileVersionInfoSize(szFilename, &dwDummy);
		if(dwSize == 0)
		{
			Logging::LogF("[BL2SDK] ERROR: GetFileVersionInfoSize failed with error %d\n", GetLastError());
			return false;
		}
		
		LPBYTE lpVersionInfo = new BYTE[dwSize];

		// Load the version info
		if(!GetFileVersionInfo(szFilename, NULL, dwSize, &lpVersionInfo[0]))
		{
			Logging::LogF("[BL2SDK] ERROR: GetFileVersionInfo failed with error %d\n", GetLastError());
			return false;
		}

		// Get the version strings
		VS_FIXEDFILEINFO* lpFfi;
		unsigned int iProductVersionLen = 0;

		if(!VerQueryValue(&lpVersionInfo[0], L"\\", (LPVOID*)&lpFfi, &iProductVersionLen))
		{
			Logging::Log("[BL2SDK] ERROR: Can't obtain FixedFileInfo from resources\n");
			return false;
		}

		DWORD fileVersionMS = lpFfi->dwFileVersionMS;
		DWORD fileVersionLS = lpFfi->dwFileVersionLS;

		delete[] lpVersionInfo;

		appVersion = Util::Format(L"%d.%d.%d.%d", 
			HIWORD(fileVersionMS),
			LOWORD(fileVersionMS),
			HIWORD(fileVersionLS),
			LOWORD(fileVersionLS));

		return true;
	}

	// TODO: Make less shit
	void HookGame()
	{
		CSigScan sigscan(L"Borderlands2.exe");

		// Sigscan for GOBjects
		pGObjects = *(unsigned long*)sigscan.Scan((unsigned char*)GObjects_Pattern, GObjects_Mask);
		Logging::LogF("[Internal] GObjects = 0x%X\n", pGObjects);

		// Sigscan for GNames
		pGNames = *(unsigned long*)sigscan.Scan((unsigned char*)GNames_Pattern, GNames_Mask);
		Logging::LogF("[Internal] GNames = 0x%X\n", pGNames);

		// Sigscan for UObject::ProcessEvent which will be used for pretty much everything
		pProcessEvent = reinterpret_cast<tProcessEvent>(sigscan.Scan((unsigned char*)ProcessEvent_Pattern, ProcessEvent_Mask));
		Logging::LogF("[Internal] UObject::ProcessEvent() = 0x%X\n", pProcessEvent);

		// Sigscan for UObject::GObjHash
		pGObjHash = *(unsigned long*)sigscan.Scan((unsigned char*)GObjHash_Pattern, GObjHash_Mask);
		Logging::LogF("[Internal] GObjHash = 0x%X\n", pGObjHash);

		// Sigscan for Unreal exception handler
		void* addrUnrealEH = sigscan.Scan((unsigned char*)CrashHandler_Pattern, CrashHandler_Mask);
		Logging::LogF("[Internal] Unreal Crash handler = 0x%X\n", addrUnrealEH);

		// Sigscan for UObject::CallFunction
		pCallFunction = reinterpret_cast<tCallFunction>(sigscan.Scan((unsigned char*)CallFunction_Pattern, CallFunction_Mask));
		Logging::LogF("[Internal] UObject::CallFunction() = 0x%X\n", pCallFunction);

		// Detour UObject::ProcessEvent()
		SETUP_SIMPLE_DETOUR(detProcessEvent, pProcessEvent, hkProcessEvent);
		detProcessEvent.Attach();

		// Detour Unreal exception handler
		SETUP_SIMPLE_DETOUR(detUnrealEH, addrUnrealEH, UnrealExceptionHandler);
		detUnrealEH.Attach();

		// Detour UObject::CallFunction()
		SETUP_SIMPLE_DETOUR(detCallFunction, pCallFunction, hkCallFunction);
		detCallFunction.Attach();
	}

	// This function is used to get the dimensions of the game window for Gwen's renderer
	bool GetCanvasPostRender(UObject* pCaller, UFunction* pFunction, void* pParms, void* pResult)
	{
		UGameViewportClient_eventPostRender_Parms* realParms = reinterpret_cast<UGameViewportClient_eventPostRender_Parms*>(pParms);
		UCanvas* pCanvas = realParms->Canvas;

		GwenManager::CreateCanvas(pCanvas->SizeX, pCanvas->SizeY);

		GameHooks::EngineHookManager->RemoveStaticHook(pFunction, "GetCanvas");
		return true;
	}

	// This function is used to ensure that everything gets called in the game thread once the game itself has loaded
	bool GameReady(UObject* pCaller, UFunction* pFunction, void* pParms, void* pResult) 
	{
		Logging::LogF("[GameReady] Thread: %i\n", GetCurrentThreadId());

		Logging::InitializeExtern();
		//Logging::InitializeGameConsole();
		Logging::PrintLogHeader();
	
		LuaManager::Initialize();

		ConCmdManager::Initialize();

		GameHooks::EngineHookManager->RemoveStaticHook(pFunction, "StartupSDK");

		GameHooks::EngineHookManager->Register("Function WillowGame.WillowGameViewportClient.PostRender", "GetCanvas", GetCanvasPostRender);
		return true;
	}

	void Initialize(LauncherStruct* args)
	{
		Settings::Initialize(args);

		Logging::InitializeFile(Settings::GetLogFilePath());
		Logging::Log("[Internal] Launching SDK...\n");

		if(!args->DisableCrashRpt)
		{
			CrashRptHelper::Initialize();
		}

		if(args->DisableAntiDebug)
		{
			HookAntiDebug();
		}

		HookGame();
		LogAllEvents(args->LogAllEvents);

		D3D9Hook::Initialize();

		GameHooks::EngineHookManager->Register("Function WillowGame.WillowGameInfo.InitGame", "StartupSDK", GameReady);	
	}

	// This is called when the process is closing
	// TODO: Other things might need cleaning up
	void Cleanup()
	{
		Logging::Cleanup();
	}

	extern "C" __declspec(dllexport) void LUAFUNC_LogAllEvents(bool enabled)
	{
		bLogAllEvents = enabled;
	}
}