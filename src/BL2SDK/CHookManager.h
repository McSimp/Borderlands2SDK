#ifndef CHOOKMANAGER_H
#define CHOOKMANAGER_H

#include "BL2SDK/BL2SDK.h"
#include <string>
#include <map>

typedef bool (tProcessEventHook) (UObject*, UFunction*, void*, void*);
typedef std::map<std::string, tProcessEventHook*> tHookMap;
typedef tHookMap::iterator tiHookMap;
typedef std::map<std::string, tHookMap>::iterator tiVirtualHooks;
typedef std::map<UFunction*, tHookMap>::iterator tiStaticHooks;
typedef std::pair<std::string, tProcessEventHook*> tFuncNameHookPair;

class CHookManager
{
	tHookMap* GetVirtualHookTable(const std::string& funcName);
	tHookMap* GetStaticHookTable(UFunction* pFunction);
	bool RemoveFromTable(tHookMap& hookTable, const std::string& funcName, const std::string& hookName);

public:
	std::map<std::string, tHookMap> VirtualHooks;
	std::map<UFunction*, tHookMap> StaticHooks;

	bool ProcessHooks(UObject* pCaller, UFunction* pFunction, void* pParms, void* pResult);
	void Register(const std::string& funcName, const std::string& hookName, tProcessEventHook* funcHook);
	bool Remove(const std::string& funcName, const std::string& hookName);
	void AddVirtualHook(const std::string& funcName, tFuncNameHookPair& hookPair);
	void AddStaticHook(UFunction* pFunction, tFuncNameHookPair& hookPair);
	bool RemoveStaticHook(UFunction* pFunction, const std::string& hookName);
	bool RemoveVirtualHook(const std::string& funcName, const std::string& hookName);
};

#endif