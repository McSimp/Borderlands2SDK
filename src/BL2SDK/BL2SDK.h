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
}

#endif