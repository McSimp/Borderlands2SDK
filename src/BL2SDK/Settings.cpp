#include "BL2SDK/Settings.h"
#include "BL2SDK/Exceptions.h"
#include "BL2SDK/Logging.h"

namespace Settings
{
	std::wstring binPath;
	bool developerMode;
	bool disableAntiDebug;

	void Initialize(LauncherStruct* args)
	{
		if(args == nullptr || args->BinPath == nullptr)
		{
			throw FatalSDKException(6000, "Launcher settings struct was invalid, did you use the launcher?");
		}

		binPath = args->BinPath;
		developerMode = args->DeveloperMode;
		disableAntiDebug = args->DisableAntiDebug;
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

	std::wstring GetTextureFile(const std::wstring& filename)
	{
		std::wstring newPath;
		newPath = binPath + L"textures\\" + filename;
		return newPath;
	}

	std::wstring GetLuaFile(const std::wstring& filename)
	{
		std::wstring newPath;
		newPath = binPath + L"lua\\" + filename;
		return newPath;
	}

	bool DeveloperModeEnabled()
	{
		return developerMode;
	}

	bool DisableAntiDebug()
	{
		return disableAntiDebug;
	}
}