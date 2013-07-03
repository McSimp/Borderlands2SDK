#include "BL2SDK/Settings.h"
#include "BL2SDK/Exceptions.h"
#include "BL2SDK/Logging.h"

namespace Settings
{
	std::wstring binPath;
	bool developerMode;

	void Initialize(LauncherStruct* args)
	{
		if(args == NULL || args->BinPath == NULL)
		{
			throw FatalSDKException(6000, "Launcher settings struct was invalid, did you use the launcher?");
		}

		binPath = args->BinPath;
		developerMode = args->DeveloperMode;
	}

	std::wstring GetLogFilePath()
	{
		return GetBinFile(L"BL2SDKLog.txt");
	}

	std::wstring GetBinFile(const std::wstring& filename)
	{
		std::wstring newPath;
		newPath = binPath + filename;
		return newPath;
	}

	std::wstring GetGwenFile(const std::wstring& filename)
	{
		std::wstring newPath;
		newPath = binPath + L"gwen\\" + filename;
		return newPath;
	}

	std::wstring GetLuaFile(const std::wstring& filename)
	{
		std::wstring newPath;
		newPath = binPath + L"lua\\" + filename;
		return newPath;
	}

	// If we are not launched in developer mode, enforce Lua hash checks
	bool ShouldEnforceLuaHashes()
	{
		return !developerMode;
	}
}