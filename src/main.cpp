#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include <tchar.h>
#include "BL2SDK/BL2SDK.h"
#include "Logging/Logging.h"
#include "Detours/DetourManager.h"
#include "Commands/ConCmdManager.h"
#include "Commands/ConCommand.h"
#include "LuaInterface/LuaInterface.h"
//#include "Crashrpt/include/CrashRpt.h"

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
/*
BOOL WINAPI CrashCallback(LPVOID lpvState)
{  
	// The application has crashed!
	Logging::Cleanup();
	return TRUE;
}

bool setupCrashReporting()
{
	CR_INSTALL_INFO info;  
	memset(&info, 0, sizeof(CR_INSTALL_INFO));  
	info.cb = sizeof(CR_INSTALL_INFO);    
	info.pszAppName = _T("Borderlands 2 SDK");  
	info.pszAppVersion = _T(BL2_SDK_VER);  
	info.pszUrl = _T("http://localhost/crash/crashrpt.php");  
	info.pfnCrashCallback = CrashCallback;   
	info.uPriorities[CR_HTTP] = 1;
	info.dwFlags |= CR_INST_ALL_POSSIBLE_HANDLERS;
	info.dwFlags |= CR_INST_HTTP_BINARY_ENCODING; 
	info.pszPrivacyPolicyURL = _T("http://localhost/crash/privacypolicy.html"); 

	// Install exception handlers
	int nResult = crInstall(&info);    
	if(nResult != 0)  
	{    
		// Something goes wrong. Get error message.
		TCHAR szErrorMsg[512] = _T("");        
		crGetLastErrorMsg(szErrorMsg, 512);    
		//_tprintf_s(_T("%s\n"), szErrorMsg);    
		return false;
	} 

	// Add our log file to the error report
	crAddFile2(_T(LOGFILE), NULL, _T("Log File"), CR_AF_MAKE_FILE_COPY);

	return true;
}
*/
void onAttach()
{	
	//setupCrashReporting();

	Logging::InitializeExtern();
	Logging::InitializeFile(LOGFILE);
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
			CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)onAttach, NULL, 0, NULL);
			return true;
		break;

		case DLL_PROCESS_DETACH:
			// TODO: Graceful detach
			Logging::Cleanup();
			//crUninstall();
			return true;
		break;
	}
}