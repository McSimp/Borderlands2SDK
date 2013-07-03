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
#include "BL2SDK/Exceptions.h"
#include "BL2SDK/AntiDebug.h"
#include "GUI/GwenManager.h"
#include "GameSDK/Signatues.h"
#include "LuaInterface/Exports.h"

namespace BL2SDK
{
	bool injectedCallNext = false;
	bool logAllProcessEvent = false;
	bool logAllUnrealScriptCalls = false;

	void* pGObjects;
	void* pGNames;
	void* pGObjHash;
	void* pGCRCTable;
	void* pNameHash;
	tProcessEvent pProcessEvent;
	tCallFunction pCallFunction;
	tFrameStep pFrameStep;
	tProcessDeferredMessage pProcessDeferredMessage;
	tViewportResize pViewportResize;
	void* pGwenDestructor;

	CLuaInterface* Lua;

	int EngineVersion = -1;
	int ChangelistNumber = -1;

	void __stdcall hkProcessEvent(UFunction* function, void* parms, void* result)
	{
		// Get "this"
		UObject* caller;
		_asm mov caller, ecx;

		if(injectedCallNext)
		{
			injectedCallNext = false;
			pProcessEvent(caller, function, parms, result);
			return;
		}

		if(logAllProcessEvent)
		{
			std::string callerName = caller->GetFullName();
			std::string functionName = function->GetFullName();

			Logging::LogF("===== ProcessEvent called =====\npCaller Name = %s\npFunction Name = %s\n", callerName.c_str(), functionName.c_str());
		}
		
		if(!GameHooks::ProcessEngineHooks(caller, function, parms, result))
		{
			// The engine hook manager told us not to pass this function to the engine
			return;
		}
		
		pProcessEvent(caller, function, parms, result);
	}

	void __stdcall hkCallFunction(FFrame& stack, void* const result, UFunction* function)
	{
		// Get "this"
		UObject* caller;
		_asm mov caller, ecx;

		if(logAllUnrealScriptCalls)
		{
			std::string callerName = caller->GetFullName();
			std::string functionName = function->GetFullName();

			Logging::LogF("===== CallFunction called =====\npCaller Name = %s\npFunction Name = %s\n", callerName.c_str(), functionName.c_str());
		}

		if(!GameHooks::ProcessUnrealScriptHooks(caller, stack, result, function))
		{
			// UnrealScript hook manager already took care of it
			return;
		}

		pCallFunction(caller, stack, result, function);
	}

	void InjectedCallNext()
	{
		injectedCallNext = true;
	}

	void LogAllProcessEventCalls(bool enabled)
	{
		logAllProcessEvent = enabled;
	}

	void LogAllUnrealScriptCalls(bool enabled)
	{
		logAllUnrealScriptCalls = enabled;
	}

	int UnrealExceptionHandler(unsigned int code, struct _EXCEPTION_POINTERS* ep)
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
		const wchar_t* filename = L"Borderlands2.exe";

		// Allocate a block of memory for the version info
		DWORD dummy;
		DWORD size = GetFileVersionInfoSize(filename, &dummy);
		if(size == 0)
		{
			Logging::LogF("[BL2SDK] ERROR: GetFileVersionInfoSize failed with error %d\n", GetLastError());
			return false;
		}
		
		LPBYTE versionInfo = new BYTE[size];

		// Load the version info
		if(!GetFileVersionInfo(filename, NULL, size, &versionInfo[0]))
		{
			Logging::LogF("[BL2SDK] ERROR: GetFileVersionInfo failed with error %d\n", GetLastError());
			return false;
		}

		// Get the version strings
		VS_FIXEDFILEINFO* ffi;
		unsigned int productVersionLen = 0;

		if(!VerQueryValue(&versionInfo[0], L"\\", (LPVOID*)&ffi, &productVersionLen))
		{
			Logging::Log("[BL2SDK] ERROR: Can't obtain FixedFileInfo from resources\n");
			return false;
		}

		DWORD fileVersionMS = ffi->dwFileVersionMS;
		DWORD fileVersionLS = ffi->dwFileVersionLS;

		delete[] versionInfo;

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
		pGObjects = *(void**)sigscan.Scan(Signatures::GObjects);
		Logging::LogF("[Internal] GObjects = 0x%p\n", pGObjects);

		// Sigscan for GNames
		pGNames = *(void**)sigscan.Scan(Signatures::GNames);
		Logging::LogF("[Internal] GNames = 0x%p\n", pGNames);

		// Sigscan for UObject::ProcessEvent which will be used for pretty much everything
		pProcessEvent = reinterpret_cast<tProcessEvent>(sigscan.Scan(Signatures::ProcessEvent));
		Logging::LogF("[Internal] UObject::ProcessEvent() = 0x%p\n", pProcessEvent);

		// Sigscan for UObject::GObjHash
		pGObjHash = *(void**)sigscan.Scan(Signatures::GObjHash);
		Logging::LogF("[Internal] GObjHash = 0x%p\n", pGObjHash);

		// Sigscan for GCRCTable
		pGCRCTable = *(void**)sigscan.Scan(Signatures::GCRCTable);
		Logging::LogF("[Internal] GCRCTable = 0x%p\n", pGCRCTable);

		// Sigscan for NameHash
		pNameHash = *(void**)sigscan.Scan(Signatures::NameHash);
		Logging::LogF("[Internal] NameHash = 0x%p\n", pNameHash);

		// Sigscan for Unreal exception handler
		void* addrUnrealEH = sigscan.Scan(Signatures::CrashHandler);
		Logging::LogF("[Internal] Unreal Crash handler = 0x%p\n", addrUnrealEH);

		// Sigscan for UObject::CallFunction
		pCallFunction = reinterpret_cast<tCallFunction>(sigscan.Scan(Signatures::CallFunction));
		Logging::LogF("[Internal] UObject::CallFunction() = 0x%p\n", pCallFunction);

		// Sigscan for FFrame::Step
		pFrameStep = reinterpret_cast<tFrameStep>(sigscan.Scan(Signatures::FrameStep));
		Logging::LogF("[Internal] FFrame::Step() = 0x%p\n", pFrameStep);

		// Sigscan for FWindowsViewport::ProcessDeferredMessage
		pProcessDeferredMessage = reinterpret_cast<tProcessDeferredMessage>(sigscan.Scan(Signatures::ProcessDeferredMessage));
		Logging::LogF("[Internal] FWindowsViewport::ProcessDeferredMessage() = 0x%p\n", pProcessDeferredMessage);

		// Sigscan for FWindowsViewport::Resize
		pViewportResize = reinterpret_cast<tViewportResize>(sigscan.Scan(Signatures::ViewportResize));
		Logging::LogF("[Internal] FWindowsViewport::Resize() = 0x%p\n", pViewportResize);

		// Sigscan for Gwen::Controls::Base::~Base()
		CSigScan sdkSigscan(L"BL2SDKDLL.dll");

		pGwenDestructor = reinterpret_cast<void*>(sdkSigscan.Scan(Signatures::GwenDestructor));
		Logging::LogF("[Internal] Gwen::Controls::Base::~Base() = 0x%p\n", pGwenDestructor);

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
	// It will also initialize Lua and the command system, so the SDK is essentially fully operational at this point
	bool GetCanvasPostRender(UObject* caller, UFunction* function, void* parms, void* result)
	{
		UGameViewportClient_eventPostRender_Parms* realParms = reinterpret_cast<UGameViewportClient_eventPostRender_Parms*>(parms);
		UCanvas* canvas = realParms->Canvas;

		GwenManager::UpdateCanvas(canvas->SizeX, canvas->SizeY);

		Lua = new CLuaInterface();
		Lua->InitializeModules();

		ConCmdManager::Initialize();

		GameHooks::EngineHookManager->RemoveStaticHook(function, "GetCanvas");
		return true;
	}

	void InitializeGameVersions()
	{
		UObject* obj = UObject::StaticClass(); // Any UObject* will do
		EngineVersion = obj->GetEngineVersion();
		ChangelistNumber = obj->GetBuildChangelistNumber();

		CrashRptHelper::AddProperty(L"EngineVersion", Util::Format(L"%d", EngineVersion));
		CrashRptHelper::AddProperty(L"ChangelistNumber", Util::Format(L"%d", ChangelistNumber));

		Logging::LogF("[Internal] Engine Version = %d, Build Changelist = %d\n", EngineVersion, ChangelistNumber);
	}

	// This function is used to ensure that everything gets called in the game thread once the game itself has loaded
	bool GameReady(UObject* caller, UFunction* function, void* parms, void* result) 
	{
		Logging::LogF("[GameReady] Thread: %i\n", GetCurrentThreadId());

#ifdef _DEBUG
		Logging::InitializeExtern();
#endif
		Logging::InitializeGameConsole();
		Logging::PrintLogHeader();

		InitializeGameVersions();

		// Set console key to Tilde if not already set
		UConsole* console = UObject::FindObject<UConsole>("WillowConsole WillowGameEngine.WillowGameViewportClient.WillowConsole");
		if(console && (console->ConsoleKey == FName("None") || console->ConsoleKey == FName("Undefine")))
		{
			console->ConsoleKey = FName("Tilde");
		}

		GameHooks::EngineHookManager->RemoveStaticHook(function, "StartupSDK");

		GameHooks::EngineHookManager->Register("Function WillowGame.WillowGameViewportClient.PostRender", "GetCanvas", &GetCanvasPostRender);
		return true;
	}

	void Initialize(LauncherStruct* args)
	{
		Settings::Initialize(args);

		Logging::InitializeFile(Settings::GetLogFilePath());
		Logging::Log("[Internal] Launching SDK...\n");

		Logging::LogF("[Internal] DisableAntiDebug = %d, LogAllProcessEventCalls = %d, LogAllUnrealScriptCalls = %d, DisableCrashRpt = %d, DeveloperMode = %d, BinPath = \"%ls\"\n", 
			args->DisableAntiDebug,
			args->LogAllProcessEventCalls,
			args->LogAllUnrealScriptCalls,
			args->DisableCrashRpt,
			args->DeveloperMode,
			args->BinPath);

		if(!args->DisableCrashRpt)
		{
			CrashRptHelper::Initialize();
		}

		if(args->DisableAntiDebug)
		{
			HookAntiDebug();
		}

		GameHooks::Initialize();

		HookGame();

		LogAllProcessEventCalls(args->LogAllProcessEventCalls);
		LogAllUnrealScriptCalls(args->LogAllUnrealScriptCalls);

		D3D9Hook::Initialize();

		GameHooks::EngineHookManager->Register("Function WillowGame.WillowGameInfo.InitGame", "StartupSDK", &GameReady);	
	}

	// This is called when the process is closing
	// TODO: Other things might need cleaning up
	void Cleanup()
	{
		Logging::Cleanup();
		GameHooks::Cleanup();
		delete Lua;
	}

	FFI_EXPORT void LUAFUNC_LogAllProcessEventCalls(bool enabled)
	{
		LogAllProcessEventCalls(enabled);
	}

	FFI_EXPORT void LUAFUNC_LogAllUnrealScriptCalls(bool enabled)
	{
		LogAllUnrealScriptCalls(enabled);
	}

	FFI_EXPORT char* LUAFUNC_UObjectGetFullName(UObject* obj)
	{
		return obj->GetFullName();
	}
}