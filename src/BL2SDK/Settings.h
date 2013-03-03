#ifndef SETTINGS_H
#define SETTINGS_H

#include <Windows.h>
#include <string>

struct LauncherStruct {
	bool DisableAntiDebug;
	bool LogAllEvents;
	const LPWSTR BinPath;
};

namespace Settings
{
	void Initialize(LauncherStruct* args);
	std::wstring GetLogFilePath();
	std::wstring GetBinFile(const std::wstring &filename);
}

#endif