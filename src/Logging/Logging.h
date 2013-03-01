#ifndef LOGGING_H
#define LOGGING_H
#include <string>

namespace Logging
{
	void Log(const char *szFmt, ...);
	void InitializeExtern();
	void InitializeFile(const std::wstring& fileName);
	void InitializeGameConsole();
	void PrintLogHeader();
	void Cleanup();
}

#endif