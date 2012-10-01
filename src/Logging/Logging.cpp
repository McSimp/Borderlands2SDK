#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include <stdio.h>

#include "GameSDK/GameSDK.h"
#include "Logging/Logging.h"

namespace Logging
{
	FILE*				pLogFile				= NULL;
	bool				bLogToExternalConsole	= false;
	bool				bLogToFile				= false;
	bool				bLogToGameConsole		= false;
	UWillowConsole*		pGameConsole			= NULL;

	void LogWinConsole(char *szBuff, int len)
	{
		HANDLE hOutput = GetStdHandle(STD_OUTPUT_HANDLE);

		DWORD numWritten = 0;
		WriteFile(hOutput, szBuff, len, &numWritten, NULL);
	}

	void Log(const char *szFmt, ...)
	{
		va_list args;
		va_start(args, szFmt);

		int buffSize = _vscprintf(szFmt, args) + 1;

		if (buffSize <= 1)
			return;

		char *szBuff = new char[buffSize];
		memset(szBuff, 0, buffSize);

		int len = vsprintf_s(szBuff, buffSize, szFmt, args);

		szBuff[buffSize - 1] = 0;

		if(bLogToExternalConsole)
			LogWinConsole(szBuff, len);

		if(bLogToFile)
		{
			if(pLogFile != NULL)
			{
				fputs(szBuff, pLogFile);
				fflush(pLogFile);
			}
		}

		if(bLogToGameConsole)
		{
			if(pGameConsole != NULL)
			{
				wchar_t* wa = new wchar_t[len];
				mbstowcs(wa, szBuff, len);
				pGameConsole->eventOutputText(FString(wa));
				delete[] wa;
			}
		}

		delete[] szBuff;
	}

	void InitializeExtern()
	{
		AllocConsole();
		bLogToExternalConsole = true;
	}

	void InitializeFile(const char *fileName)
	{
		pLogFile = fopen(fileName, "w");
		bLogToFile = true;
	}

	void InitializeGameConsole()
	{
		// There should only be 1 instance so we should be right to just use it in this way
		UWillowConsole* console = UObject::FindObject<UWillowConsole>("WillowConsole WillowGameEngine.WillowGameViewportClient.WillowConsole");
		
		if(console != NULL)
		{
			pGameConsole = console;
			bLogToGameConsole = true;
		}
	}

	void PrintLogHeader()
	{
		Log("======== BL2 Mod SDK %s ========\n", BL2_SDK_VER);
	}
}