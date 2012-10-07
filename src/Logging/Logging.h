#ifndef LOGGING_H
#define LOGGING_H

#define LOGFILE "BL2SDKLog.txt"

namespace Logging
{
	void Log(const char *szFmt, ...);
	void InitializeExtern();
	void InitializeFile(const char *fileName);
	void InitializeGameConsole();
	void PrintLogHeader();
	void Cleanup();
}

#endif