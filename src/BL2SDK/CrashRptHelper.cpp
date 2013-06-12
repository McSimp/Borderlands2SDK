#include "BL2SDK/BL2SDK.h"
#include "BL2SDK/CrashRptHelper.h"
#include "BL2SDK/Settings.h"
#include "BL2SDK/Logging.h"
#include "BL2SDK/Util.h"
#include "generated/SDKVersion.h"

#define CRASHRPT_ERROR(name) TCHAR (##name)[256]; crGetLastErrorMsgW(##name, 256);

namespace CrashRptHelper
{
	bool crashRptReady = false;

	BOOL WINAPI CrashCallback(LPVOID lpvState)
	{
		BL2SDK::Cleanup();
		return CR_CB_DODEFAULT;
	}

	bool Initialize()
	{		
		// Setup the crash reporter
		CR_INSTALL_INFO info;  
		memset(&info, 0, sizeof(CR_INSTALL_INFO));  
		info.cb = sizeof(CR_INSTALL_INFO);    
		info.pszAppName = L"Borderlands 2 SDK";  
		info.pszAppVersion = BL2SDK::VersionW.c_str();
		info.pszUrl = L"http://mcsi.mp/cr/crashrpt.php";  
		info.pfnCrashCallback = CrashCallback;   
		info.uPriorities[CR_HTTP] = 1;
		info.dwFlags |= CR_INST_ALL_POSSIBLE_HANDLERS;
		info.dwFlags |= CR_INST_HTTP_BINARY_ENCODING; 
		//info.pszPrivacyPolicyURL = L"http://mcsi.mp/cr/privacy.html"; 

		// Install exception handlers
		int result = crInstallW(&info);    
		if(result != 0)
		{    
			// Something goes wrong. Get error message.
			CRASHRPT_ERROR(szErrorMsg)
			Logging::LogF("[CrashRpt] ERROR: Failed to install CrashRpt. Result = %i, Error = %ls\n", result, szErrorMsg);
			return false;
		} 

		crashRptReady = true;
		
		// Add our log file to the error report
		crAddFile2W(Settings::GetLogFilePath().c_str(), NULL, L"Log File", CR_AF_MAKE_FILE_COPY);

		// Add the version of Borderlands 2 to the report if it can be obtained
		std::wstring gameVer;
		if(BL2SDK::GetGameVersion(gameVer))
		{
			crAddPropertyW(L"BL2VER", gameVer.c_str());
		}

		// Add the bin path
		crAddPropertyW(L"BinPath", Settings::GetBinFile(L"").c_str());

		Logging::Log("[CrashRpt] Crash reporting successfully initialized\n");

		return true;
	}

	void AddProperty(const std::wstring& propertyName, const std::wstring& value)
	{
		if(!crashRptReady) return;
		crAddPropertyW(propertyName.c_str(), value.c_str());
	}

	void Cleanup()
	{
		if(!crashRptReady) return;
		crUninstall();
	}

	void SoftCrash(int code = 0)
	{
		if(!crashRptReady)
		{
			Logging::Log("[CrashRpt] Cannot report error - CrashRpt is not initialized properly\n");
			return;
		}

		CR_EXCEPTION_INFO ei;
		memset(&ei, 0, sizeof(CR_EXCEPTION_INFO));
		ei.cb = sizeof(CR_EXCEPTION_INFO);
		ei.exctype = CR_SEH_EXCEPTION;
		ei.code = code;
		ei.bManual = true;
		if(crGenerateErrorReport(&ei) != 0)
		{
			Util::Popup(L"SDK Error", L"An error occurred in the BL2 SDK, please check the logfile for details.");
		}

		Util::CloseGame();
	}

	bool GenerateReport(unsigned int code, PEXCEPTION_POINTERS ep)
	{
		if(!crashRptReady)
		{
			Logging::Log("[CrashRpt] Cannot generate report - CrashRpt is not initialized properly\n");
			return false;
		}

		CR_EXCEPTION_INFO ei;
		memset(&ei, 0, sizeof(CR_EXCEPTION_INFO));
		ei.cb = sizeof(CR_EXCEPTION_INFO);
		ei.exctype = CR_SEH_EXCEPTION;
		ei.code = code;
		ei.pexcptrs = ep;
		int result = crGenerateErrorReport(&ei);
		if(result != 0)
		{
			CRASHRPT_ERROR(szErrorMsg)
			Logging::LogF("[CrashRpt] ERROR: Failed to generate report. Result = %i, Error = %ls\n", result, szErrorMsg);
			return false;
		}
		else
		{
			return true;
		}
	}
}