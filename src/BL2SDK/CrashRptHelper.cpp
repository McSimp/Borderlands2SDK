#include "BL2SDK/BL2SDK.h"
#include "BL2SDK/CrashRptHelper.h"
#include "BL2SDK/Settings.h"
#include "Logging/Logging.h"
#include "BL2SDK/Util.h"

// Am I a horrible person for using this?
#define CRASHRPTFUNC(func) p##func = (p##func##t)GetProcAddress(hCrashRpt, #func)

namespace CrashRptHelper
{
	typedef int (WINAPI *pcrInstallWt)(PCR_INSTALL_INFOW);
	typedef int (WINAPI *pcrUninstallt)();
	typedef int (WINAPI *pcrGetLastErrorMsgWt)(LPWSTR pszBuffer, UINT uBuffSize);
	typedef int (WINAPI *pcrAddFile2Wt)(LPCWSTR pszFile, LPCWSTR pszDestFile, LPCWSTR pszDesc, DWORD dwFlags);
	//typedef int (WINAPI *pcrInstallToCurrentThread2t)(DWORD dwFlags);
	typedef int (WINAPI *pcrGenerateErrorReportt)(CR_EXCEPTION_INFO* pExceptionInfo);
	typedef int (WINAPI *pcrAddPropertyWt)(LPCWSTR pszPropName, LPCWSTR pszPropValue);

	HMODULE hCrashRpt = NULL;
	pcrInstallWt pcrInstallW = NULL; 
	pcrUninstallt pcrUninstall = NULL;
	pcrGetLastErrorMsgWt pcrGetLastErrorMsgW = NULL;
	pcrAddFile2Wt pcrAddFile2W = NULL;
	//pcrInstallToCurrentThread2t pcrInstallToCurrentThread2 = NULL;
	pcrGenerateErrorReportt pcrGenerateErrorReport = NULL;
	pcrAddPropertyWt pcrAddPropertyW = NULL;

	bool GetGameVersion(std::wstring& appVersion)
	{
		wchar_t* szFilename = L"Borderlands2.exe";

		// Allocate a block of memory for the version info
		DWORD dwDummy;
		DWORD dwSize = GetFileVersionInfoSize(szFilename, &dwDummy);
		if(dwSize == 0)
		{
			Logging::Log("[CrashRpt] GetFileVersionInfoSize failed with error %d\n", GetLastError());
			return false;
		}
		
		LPBYTE lpVersionInfo = new BYTE[dwSize];

		// Load the version info
		if(!GetFileVersionInfo(szFilename, NULL, dwSize, &lpVersionInfo[0]))
		{
			Logging::Log("[CrashRpt] GetFileVersionInfo failed with error %d\n", GetLastError());
			return false;
		}

		// Get the version strings
		VS_FIXEDFILEINFO* lpFfi;
		unsigned int iProductVersionLen = 0;

		if(!VerQueryValue(&lpVersionInfo[0], L"\\", (LPVOID*)&lpFfi, &iProductVersionLen))
		{
			Logging::Log("[CrashRpt] Can't obtain FixedFileInfo from resources\n");
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

		Logging::Log("[CrashRpt] Game Version = %ls\n", appVersion.c_str());

		return true;
	}

	BOOL WINAPI CrashCallback(LPVOID lpvState)
	{
		Logging::Cleanup();
		return CR_CB_DODEFAULT;
	}

	bool Initialize()
	{		
		std::wstring dllPath = Settings::GetBinFile(L"CrashRpt1400d.dll");

		// Load the crashrpt dll
		hCrashRpt = LoadLibrary(dllPath.c_str());
		if(hCrashRpt == NULL)
		{
			Logging::Log("[CrashRpt] Failed to load CrashRpt library\n");
			return false;
		}

		// Get a pointers to cr functions
		CRASHRPTFUNC(crInstallW);
		CRASHRPTFUNC(crUninstall);
		CRASHRPTFUNC(crGetLastErrorMsgW);
		CRASHRPTFUNC(crAddFile2W);
		//CRASHRPTFUNC(crInstallToCurrentThread2);
		CRASHRPTFUNC(crGenerateErrorReport);
		CRASHRPTFUNC(crAddPropertyW);

		if(!pcrInstallW || !pcrUninstall || !pcrGetLastErrorMsgW || !pcrAddFile2W /*|| !pcrInstallToCurrentThread2*/ || !pcrGenerateErrorReport || !pcrAddPropertyW)
		{
			Logging::Log("[CrashRpt] Failed to find all CrashRpt functions\n");
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
		//info.pszPrivacyPolicyURL = L"http://localhost/crash/privacypolicy.html"; 

		// Install exception handlers
		int result = pcrInstallW(&info);    
		if(result != 0)
		{    
			// Something goes wrong. Get error message.
			TCHAR szErrorMsg[256];        
			pcrGetLastErrorMsgW(szErrorMsg, 256);    
			Logging::Log("[CrashRpt] Failed to install CrashRpt. Result = %i, Error = %ls\n", result, szErrorMsg);
			return false;
		} 
		
		// Add our log file to the error report
		pcrAddFile2W(Settings::GetLogFilePath().c_str(), NULL, L"Log File", CR_AF_MAKE_FILE_COPY);

		// Add the version of Borderlands 2 to the report if it can be obtained
		std::wstring gameVer;
		if(GetGameVersion(gameVer))
		{
			pcrAddPropertyW(L"BL2VER", gameVer.c_str());
		}

		return true;
	}

	void Cleanup()
	{
		pcrUninstall();
		FreeLibrary(hCrashRpt);
	}

	/*
	int InstallThread()
	{
		return pcrInstallToCurrentThread2(0);
	}
	*/

	bool SoftCrash()
	{
		CR_EXCEPTION_INFO ei;
		memset(&ei, 0, sizeof(CR_EXCEPTION_INFO));
		ei.cb = sizeof(CR_EXCEPTION_INFO);
		ei.exctype = CR_CPP_SIGTERM;
		ei.bManual = true;
		return (pcrGenerateErrorReport(&ei) == 0);
	}

	bool GenerateReport(unsigned int code, PEXCEPTION_POINTERS ep)
	{
		CR_EXCEPTION_INFO ei;
		memset(&ei, 0, sizeof(CR_EXCEPTION_INFO));
		ei.cb = sizeof(CR_EXCEPTION_INFO);
		ei.exctype = CR_SEH_EXCEPTION;
		ei.code = code;
		ei.pexcptrs = ep;
		int result = pcrGenerateErrorReport(&ei);
		if(result != 0)
		{
			TCHAR szErrorMsg[256];
			pcrGetLastErrorMsgW(szErrorMsg, 256);
			Logging::Log("[CrashRpt] Failed to generate report. Result = %i, Error = %ls\n", result, szErrorMsg);
			return false;
		}
		else
		{
			return true;
		}
	}
}