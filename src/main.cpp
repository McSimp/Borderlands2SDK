#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include "BL2SDK/BL2SDK.h"
#include "BL2SDK/Logging.h"
#include "BL2SDK/CrashRptHelper.h"
#include "BL2SDK/Util.h"
#include "BL2SDK/Exceptions.h"
#include "BL2SDK/Settings.h"

extern "C" __declspec(dllexport) DWORD InitializeSDK(LPVOID lpParameter)
{
	// The launcher will pass the configuration settings through lpParameter parameter as a struct
	LauncherStruct* args = reinterpret_cast<LauncherStruct*>(lpParameter);

	try
	{
		BL2SDK::Initialize(args);
	}
	catch(FatalSDKException &ex)
	{
		Util::Popup(L"SDK Error", Util::Widen(ex.what()));
		Logging::LogF("[ERROR] FatalSDKException(%d): %s\n", ex.GetErrorCode(), ex.what());
		CrashRptHelper::SoftCrash(ex.GetErrorCode());
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
			//BL2SDK::Cleanup();
			return FALSE;
		break;
	}
}