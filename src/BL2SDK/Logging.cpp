#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include <stdio.h>

#include "BL2SDK/BL2SDK.h"
#include "BL2SDK/Logging.h"
#include "BL2SDK/Util.h"
#include "BL2SDK/Exceptions.h"

namespace Logging
{
	HANDLE logFile = NULL;
	bool logToExternalConsole = false;
	bool logToFile = false;
	bool logToGameConsole = false;
	UConsole* gameConsole = NULL;

	void LogToFile(const char* buff, int len)
	{
		if(logFile != INVALID_HANDLE_VALUE)
		{
			// Write to the log file. 0 fucks given if it fails.
			DWORD bytesWritten = 0;
			WriteFile(logFile, buff, len, &bytesWritten, NULL);
		}
	}

	void LogWinConsole(const char* buff, int len)
	{
		HANDLE output = GetStdHandle(STD_OUTPUT_HANDLE);
		DWORD bytesWritten = 0;
		WriteFile(output, buff, len, &bytesWritten, NULL);
	}

	void Log(const char* formatted, int length)
	{
		if(length == 0)
			length = strlen(formatted);

		if(logToExternalConsole)
			LogWinConsole(formatted, length);

		if(logToFile)
			LogToFile(formatted, length);
		
		if(logToGameConsole)
		{
			if(gameConsole != NULL)
			{
				std::wstring wfmt = Util::Widen(formatted);
				BL2SDK::InjectedCallNext();
				gameConsole->eventOutputText(FString((wchar_t*)wfmt.c_str()));
			}
		}
	}

	void LogF(const char* fmt, ...)
	{
		va_list args;
		va_start(args, fmt);
		std::string formatted = Util::FormatInternal(fmt, args); 
		va_end(args);

		Log(formatted.c_str(), formatted.length());
	}

	void InitializeExtern()
	{
		BOOL result = AllocConsole();
		if(result)
		{
			logToExternalConsole = true;
		}
	}

	// Everything else can fail, but InitializeFile must work.
	void InitializeFile(const std::wstring& fileName)
	{
		logFile = CreateFile(fileName.c_str(), GENERIC_WRITE, FILE_SHARE_READ, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
		if(logFile == INVALID_HANDLE_VALUE)
		{
			throw FatalSDKException(1000, "Failed to initialize log file (INVALID_HANDLE_VALUE)");
		}
		
		logToFile = true;
	}

	// TODO: Cleanup
	void InitializeGameConsole()
	{
		// There should only be 1 instance so we should be right to just use it in this way
		UConsole* console = UObject::FindObject<UConsole>("WillowConsole WillowGameEngine.WillowGameViewportClient.WillowConsole");

		if(console != NULL)
		{
			gameConsole = console;
			logToGameConsole = true;
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
		if(logFile != INVALID_HANDLE_VALUE)
		{
			FlushFileBuffers(logFile);
			CloseHandle(logFile);
		}
	}
}