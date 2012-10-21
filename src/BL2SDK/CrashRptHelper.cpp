#include "BL2SDK/BL2SDK.h"
#include "BL2SDK/CrashRptHelper.h"
#include "BL2SDK/Settings.h"
#include "Logging/Logging.h"

#include <sstream>

namespace CrashRptHelper
{
	typedef int (WINAPI *pcrInstallWt)(PCR_INSTALL_INFOW);
	typedef int (WINAPI *pcrUninstallt)();
	typedef int (WINAPI *pcrGetLastErrorMsgWt)(LPWSTR pszBuffer, UINT uBuffSize);
	typedef int (WINAPI *pcrAddFile2Wt)(LPCWSTR pszFile, LPCWSTR pszDestFile, LPCWSTR pszDesc, DWORD dwFlags);

	HMODULE hCrashRpt = NULL;
	pcrInstallWt pcrInstallW = NULL; 
	pcrUninstallt pcrUninstall = NULL;
	pcrGetLastErrorMsgWt pcrGetLastErrorMsgW = NULL;
	pcrAddFile2Wt pcrAddFile2W = NULL;

	BOOL WINAPI CrashCallback(LPVOID lpvState)
	{  
		OutputDebugStringW(L"Crashed!");
		Logging::Cleanup();
		return CR_CB_DODEFAULT;
	}

	bool Initialize()
	{
		// Get path to the library
		//std::wostringstream ss;
		//ss << Settings::GetBinFile(L"CrashRpt");
		//ss << CRASHRPT_VER;
#ifdef _DEBUG
		//ss << L"d";
#endif
		//ss << L".dll";
		//const wchar_t* ptr = ss.str().c_str();
		std::wstring dllPath = Settings::GetBinFile(L"CrashRpt1400d.dll");
		OutputDebugStringW(dllPath.c_str());

		// Load the crashrpt dll
		hCrashRpt = LoadLibrary(dllPath.c_str());
		if(hCrashRpt == NULL)
		{
			OutputDebugStringW(L"Failed to load library crashrpt");
			return false;
		}

		// Get a pointers to cr functions
		pcrInstallWt pcrInstallW = (pcrInstallWt)GetProcAddress(hCrashRpt, "crInstallW");
		pcrUninstallt pcrUninstall = (pcrUninstallt)GetProcAddress(hCrashRpt, "crUninstall");
		pcrGetLastErrorMsgWt pcrGetLastErrorMsgW = (pcrGetLastErrorMsgWt)GetProcAddress(hCrashRpt, "crGetLastErrorMsgW");
		pcrAddFile2Wt pcrAddFile2W = (pcrAddFile2Wt)GetProcAddress(hCrashRpt, "crAddFile2W");

		if(!pcrInstallW || !pcrUninstall || !pcrGetLastErrorMsgW || !pcrAddFile2W)
		{
			OutputDebugStringW(L"Failed on finding functions");
			return false;
		}

		// Setup the crash reporter
		CR_INSTALL_INFO info;  
		memset(&info, 0, sizeof(CR_INSTALL_INFO));  
		info.cb = sizeof(CR_INSTALL_INFO);    
		info.pszAppName = L"Borderlands 2 SDK";  
		info.pszAppVersion = BL2SDK::VersionW.c_str();  
		info.pszUrl = L"http://localhost/crash/crashrpt.php";  
		info.pfnCrashCallback = CrashCallback;   
		info.uPriorities[CR_HTTP] = 1;
		info.dwFlags |= CR_INST_ALL_POSSIBLE_HANDLERS;
		info.dwFlags |= CR_INST_HTTP_BINARY_ENCODING; 
		info.pszPrivacyPolicyURL = L"http://localhost/crash/privacypolicy.html"; 

		// Install exception handlers
		int nResult = pcrInstallW(&info);    
		if(nResult != 0)
		{    
			// Something goes wrong. Get error message.
			//TCHAR szErrorMsg[512] = L"";        
			//pcrGetLastErrorMsgW(szErrorMsg, 512);    
			OutputDebugStringW(L"Failed on installling crashrpt");
			return false;
		} 

		// Add our log file to the error report
		pcrAddFile2W(Settings::GetLogFilePath().c_str(), NULL, L"Log File", CR_AF_MAKE_FILE_COPY);

		OutputDebugStringW(L"Crashrpt installed");
		return true;
	}

	void Cleanup()
	{
		pcrUninstall();
		FreeLibrary(hCrashRpt);
	}
}