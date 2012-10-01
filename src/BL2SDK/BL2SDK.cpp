#include "BL2SDK/BL2SDK.h"
#include "Detours/DetourManager.h"
#include "Logging/Logging.h"

namespace BL2SDK
{
	bool										bInjectedCallNext = false;
	bool										bLogAllEvents = false;
	std::list<tFuncNameHookPair>				FuncsToFind;
	std::map<UFunction*, tProcessEventHook*>	HookedFunctions;

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

		// There might be a better way to do this, I don't know C++ very well
		std::string CallerName = pCaller->GetFullName();
		std::string FunctionName = pFunction->GetFullName();

		if(bLogAllEvents)
		{
			Logging::Log("===== ProcessEvent called =====\n");
			Logging::Log("pCaller Name = %s\n", CallerName.c_str());
			Logging::Log("pFunction Name = %s\n", FunctionName.c_str());
		}

		// Resolve the functions names that need to be hooked into function pointers for later
		std::list<tFuncNameHookPair>::iterator iFuncsToFind;
		//for(iFuncsToFind = FuncsToFind.begin(); iFuncsToFind != FuncsToFind.end(); iFuncsToFind++)
		iFuncsToFind = FuncsToFind.begin();
		while(iFuncsToFind != FuncsToFind.end())
		{
			tFuncNameHookPair p = *iFuncsToFind;
			if(!p.first.compare(FunctionName))
			{
				Logging::Log("[Engine Hooks] Hook created for \"%s\"\n", FunctionName);
				HookedFunctions.insert(std::make_pair(pFunction, p.second));
				iFuncsToFind = FuncsToFind.erase(iFuncsToFind);
			}
			else
			{
				iFuncsToFind++;
			}
		}

		// Call the function hook (if any) for this pFunction
		std::map<UFunction*, tProcessEventHook*>::iterator iHookedFunctions = HookedFunctions.find(pFunction);
		if(iHookedFunctions != HookedFunctions.end())
		{
			if(!iHookedFunctions->second(pCaller, pFunction, pParms, pResult))
			{
				// If the hook returns false, then don't call ProcessEvent in the engine
				_asm popad;
				return;
			}
		}

		_asm popad;
		DetourManager::pProcessEvent(pCaller, pFunction, pParms, pResult);
		return;
	}

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
			call hkProcessEvent
			pop ebp
			retn 12
		}
	}

	void InjectedCallNext()
	{
		bInjectedCallNext = true;
	}

	void LogAllEvents(bool enabled)
	{
		bLogAllEvents = enabled;
	}

	void RegisterHook(const std::string& funcName, tProcessEventHook* funcHook)
	{
		tFuncNameHookPair pair = std::make_pair(funcName, funcHook);
		FuncsToFind.push_back(pair);
	}
}