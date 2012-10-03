#ifndef CONCMDMANAGER_H
#define CONCMDMANAGER_H

#include "BL2SDK/BL2SDK.h"
#include <vector>

namespace ConCmdManager
{
	typedef std::vector<std::string> tArgsList;
	typedef void (tConCommand) (tArgsList &args); 
	typedef std::pair<std::string, tConCommand*> tFuncNameConCmdPair;

	bool eventConCommand(UObject* pCaller, UFunction* pFunction, void* pParms, void* pResult);
	void Initialize();
	void RegisterCommand(const std::string& command, tConCommand* func);
	void RegisterCommand(const tFuncNameConCmdPair& pair);
}

#endif