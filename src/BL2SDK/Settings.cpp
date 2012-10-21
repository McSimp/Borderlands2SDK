#include "BL2SDK/Settings.h"

namespace Settings
{
	HKEY hSDKKey = NULL;
	std::wstring binPath;

	LONG ReadStringKey(const std::wstring &strValueName, std::wstring &strValue)
	{
        WCHAR szBuffer[512];
        DWORD dwBufferSize = sizeof(szBuffer);
        LONG nError = RegQueryValueEx(hSDKKey, strValueName.c_str(), 0, NULL, (LPBYTE)szBuffer, &dwBufferSize);
        if(nError == ERROR_SUCCESS)
        {
			strValue = szBuffer;
        }
        return nError;
	}

	/*
	LONG ReadStringKey(const std::string &strValueName, std::string &strValue)
	{
        char szBuffer[512];
        DWORD dwBufferSize = sizeof(szBuffer);
        LONG nError = RegQueryValueExA(hSDKKey, strValueName.c_str(), 0, NULL, (LPBYTE)szBuffer, &dwBufferSize);
        if(nError == ERROR_SUCCESS)
        {
			strValue = szBuffer;
        }
        return nError;
	}
	*/

	LONG Initialize()
	{
		LONG nError = RegOpenKeyEx(HKEY_CURRENT_USER, L"Software\\BL2SDK", 0, KEY_READ, &hSDKKey);
		if(nError != ERROR_SUCCESS)
		{
			return nError;
		}
		
		nError = ReadStringKey(L"BinPath", binPath);
		if(nError != ERROR_SUCCESS)
		{
			return nError;
		}

		return nError;
	}

	// Should these be refernces?
	std::wstring GetLogFilePath()
	{
		return GetBinFile(LOGFILE);
	}

	std::wstring GetBinFile(const std::wstring &filename)
	{
		std::wstring newPath;
		newPath = binPath + filename;
		return newPath;
	}
}