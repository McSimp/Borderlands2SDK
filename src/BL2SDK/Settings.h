#ifndef SETTINGS_H
#define SETTINGS_H

#include <Windows.h>
#include <string>

#define LOGFILE L"BL2SDKLog.txt"

namespace Settings
{
	LONG Initialize();
	std::wstring GetLogFilePath();
	std::wstring GetBinFile(const std::wstring &filename);
}

#endif