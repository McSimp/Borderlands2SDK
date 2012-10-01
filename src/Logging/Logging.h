#ifndef LOGGING_H
#define LOGGING_H

namespace Logging
{
	void Log(const char *szFmt, ...);
	void InitializeExtern();
	void InitializeFile(const char *fileName);
	void InitializeGameConsole();
	void PrintLogHeader();
}

#endif