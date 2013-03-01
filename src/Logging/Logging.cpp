#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include <stdio.h>

#include "BL2SDK/BL2SDK.h"
#include "Logging/Logging.h"
#include "BL2SDK/Util.h"
#include "BL2SDK/Exceptions.h"

namespace Logging
{
	HANDLE				hLogFile				= NULL;
	bool				bLogToExternalConsole	= false;
	bool				bLogToFile				= false;
	bool				bLogToGameConsole		= false;
	UConsole*			pGameConsole			= NULL;

	void LogToFile(const char* szBuff, int len)
	{
		if(hLogFile != INVALID_HANDLE_VALUE)
		{
			// Write to the log file. 0 fucks given if it fails.
			DWORD dwBytesWritten = 0;
			WriteFile(hLogFile, szBuff, len, &dwBytesWritten, NULL);
		}
	}

	void LogWinConsole(const char* szBuff, int len)
	{
		HANDLE hOutput = GetStdHandle(STD_OUTPUT_HANDLE);
		DWORD dwBytesWritten = 0;
		WriteFile(hOutput, szBuff, len, &dwBytesWritten, NULL);
	}

	void Log(const char* formatted, int length)
	{
		if(length == 0)
			length = strlen(formatted);

		if(bLogToExternalConsole)
			LogWinConsole(formatted, length);

		if(bLogToFile)
			LogToFile(formatted, length);
		
		if(bLogToGameConsole)
		{
			if(pGameConsole != NULL)
			{
				std::wstring wfmt = Util::Widen(formatted);
				BL2SDK::InjectedCallNext();
				pGameConsole->eventOutputText(FString((wchar_t*)wfmt.c_str()));
			}
		}
	}

	void LogF(const char* szFmt, ...)
	{
		va_list args;
		va_start(args, szFmt);
		std::string formatted = Util::FormatInternal(szFmt, args); 
		va_end(args);

		Log(formatted.c_str(), formatted.length());
	}

	void InitializeExtern()
	{
		BOOL result = AllocConsole();
		if(result)
		{
			bLogToExternalConsole = true;
		}
	}

	// Everything else can fail, but InitializeFile must work.
	void InitializeFile(const std::wstring& fileName)
	{
		hLogFile = CreateFile(fileName.c_str(), GENERIC_WRITE, FILE_SHARE_READ, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
		if(hLogFile == INVALID_HANDLE_VALUE)
		{
			throw FatalSDKException(1000, "Failed to initialize log file (INVALID_HANDLE_VALUE)");
		}
		
		bLogToFile = true;
	}

	// TODO: Cleanup
	void InitializeGameConsole()
	{
		// There should only be 1 instance so we should be right to just use it in this way
		UConsole* console = UObject::FindObject<UConsole>("WillowConsole WillowGameEngine.WillowGameViewportClient.WillowConsole");

		if(console != NULL)
		{
			pGameConsole = console;
			bLogToGameConsole = true;
		}
		else
		{
			Log("[Logging] ERROR: Attempted to hook game console but 'WillowConsole WillowGameEngine.WillowGameViewportClient.WillowConsole' was not found.\n");
		}
	}

	void PrintLogHeader()
	{
		LogF("======== BL2 Mod SDK Loaded (Version %s) ========\n", BL2SDK::Version.c_str());
	}

	void Cleanup()
	{
		if(hLogFile != INVALID_HANDLE_VALUE)
		{
			FlushFileBuffers(hLogFile);
			CloseHandle(hLogFile);
		}
	}
}