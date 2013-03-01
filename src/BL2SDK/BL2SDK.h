#ifndef BL2SDK_H
#define BL2SDK_H

#include "GameSDK/GameSDK.h"

#include <string>

namespace BL2SDK
{
	typedef void (__thiscall *tProcessEvent) (UObject*, UFunction*, void*, void*);
	//typedef int (tUnrealEH) (unsigned int, struct _EXCEPTION_POINTERS*);

	void LogAllEvents(bool enabled);
	bool GetGameVersion(std::wstring& appVersion);
	void InjectedCallNext();
	void Initialize();

	const std::string Version = "October 21 2012";
	const std::wstring VersionW = L"October 21 2012";
}

#endif