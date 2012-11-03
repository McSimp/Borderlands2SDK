#ifndef ENGINEHOOKS_H
#define ENGINEHOOKS_H

#include "BL2SDK/BL2SDK.h"
#include <string>

namespace EngineHooks
{
	typedef bool (tProcessEventHook) (UObject*, UFunction*, void*, void*);
	
	bool ProcessHooks(UObject* pCaller, UFunction* pFunction, void* pParms, void* pResult);
	void Register(const std::string& funcName, const std::string& hookName, tProcessEventHook* funcHook);
	bool Remove(const std::string& funcName, const std::string& hookName);
	bool RemoveStaticHook(UFunction* pFunction, const std::string& hookName);
	bool RemoveVirtualHook(const std::string& funcName, const std::string& hookName);
}

#endif