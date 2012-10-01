#ifndef CONCMDMANAGER_H
#define CONCMDMANAGER_H

#include <vector>

namespace ConCmdManager
{
	typedef std::vector<std::string> tArgsList;
	typedef void (tConCommand) (tArgsList &args); 

	bool eventConCommand(UObject* pCaller, UFunction* pFunction, void* pParms, void* pResult);
	void Initialize();
	void RegisterCommand(const std::string& command, tConCommand* func);
}

#endif