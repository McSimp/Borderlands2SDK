#include "BL2SDK/BL2SDK.h"
#include "Detours/DetourManager.h"
#include "Logging/Logging.h"

#include <string>
#include <list>
#include <map>

namespace BL2SDK
{
	typedef void (tProcessEventHook) (UObject*, UFunction*, void*, void*);
	typedef std::pair<std::string, tProcessEventHook*> tFuncNameHookPair;

	bool										bInjectedCallNext = false;
	bool										bLogAllEvents = false;
	std::list<tFuncNameHookPair>				FuncsToFind;
	std::map<UFunction*, tProcessEventHook*>	HookedFunctions;

	void __declspec(naked) hkRawProcessEvent()
	{
		__asm
		{
			push ebp
			mov ebp, esp
			push [ebp+16]
			push [ebp+12]
			push [ebp+8]
			push ecx
			call BL2SDK::hkProcessEvent
			pop ebp
			retn 12
		}
	}

	void __stdcall hkProcessEvent(UObject* pCaller, UFunction* pFunction, void* pParms, void* pResult)
	{
		// Save the registers
		_asm pushad;

		if(bInjectedCallNext)
		{
			bInjectedCallNext = false;
			_asm popad;
			DetourManager::pProcessEvent(pCaller, pFunction, pParms, pResult);
			return;
		}

		/*
		if(!pFunction || !pCaller)
		{
			_asm popad;
			DetourManager::pProcessEvent(pCaller, pFunction, pParms, pResult);
			return;
		}
		*/

		// There might be a better way to do this, I don't know C++ very well
		std::string CallerName = pCaller->GetFullName();
		std::string FunctionName = pFunction->GetFullName();

		if(bLogAllEvents)
		{
			Logging::Log("===== ProcessEvent called =====\n");
			Logging::Log("pCaller Name = %s\n", CallerName.c_str());
			Logging::Log("pFunction Name = %s\n", FunctionName.c_str());
		}

		//std::list<std::string>::iterator iFuncsToFind;

		_asm popad;
		DetourManager::pProcessEvent(pCaller, pFunction, pParms, pResult);
		return;
	}

	void LogAllEvents(bool enabled)
	{
		bLogAllEvents = enabled;
	}
}