#ifndef LOGGING_H
#define LOGGING_H

namespace Logging
{
	void Log(const char *szFmt, ...);
	bool InitializeExtern();
	bool InitializeFile(std::wstring &fileName);
	void InitializeGameConsole();
	void PrintLogHeader();
	void Cleanup();
}

#endif