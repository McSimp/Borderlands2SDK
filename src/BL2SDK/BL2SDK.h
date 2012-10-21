#ifndef BL2SDK_H
#define BL2SDK_H

#include "GameSDK/GameSDK.h"

#include <string>
#include <list>
#include <map>

namespace BL2SDK
{
	typedef bool (tProcessEventHook) (UObject*, UFunction*, void*, void*);
	typedef std::pair<std::string, tProcessEventHook*> tFuncNameHookPair;

	void hkRawProcessEvent();
	void LogAllEvents(bool enabled);
	void InjectedCallNext();
	void RegisterHook(const std::string& funcName, tProcessEventHook* funcHook);
	void RemoveHook(UFunction* pFunction);
	bool Initialize();

	const std::string Version = "October 21 2012";
	const std::wstring VersionW = L"October 21 2012";
}

#endif