#ifndef GAMEHOOKS_H
#define GAMEHOOKS_H

#include "BL2SDK/CHookManager.h"

namespace GameHooks
{
	extern CHookManager* EngineHookManager;
	extern CHookManager* UnrealScriptHookManager;

	void Initialize();
	bool ProcessEngineHooks(UObject* pCaller, UFunction* pFunction, void* pParms, void* pResult);
}

#endif