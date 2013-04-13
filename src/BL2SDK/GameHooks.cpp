#include "BL2SDK/GameHooks.h"
#include "BL2SDK/Logging.h"

namespace GameHooks
{
	CHookManager<tProcessEventHook>* EngineHookManager;
	//CHookManager* UnrealScriptHookManager;
	
	void Initialize()
	{
		EngineHookManager = new CHookManager<tProcessEventHook>();
		Logging::LogF("[GameHooks] EngineHookManager = 0x%X\n", EngineHookManager);

		//UnrealScriptHookManager = new CHookManager();
		//Logging::LogF("[GameHooks] UnrealScriptHookManager = 0x%X\n", UnrealScriptHookManager);
	}

	bool ProcessEngineHooks(UObject* pCaller, UFunction* pFunction, void* pParms, void* pResult)
	{
		EngineHookManager->ResolveVirtualHooks(pFunction);

		// Call any static hooks that may exist
		CHookManager<tProcessEventHook>::tHookMap* hooks = EngineHookManager->GetStaticHookTable(pFunction);

		if(hooks != NULL)
		{
			// TODO: Still not sure on best implementation here. Would it be better
			// just to stop every single next hook if one returns false?
			bool engineShouldRun = true;
			for(CHookManager<tProcessEventHook>::tiHookMap iterator = hooks->begin(); iterator != hooks->end(); iterator++)
			{
				// maps to std::string, tProcessEventHook*
				if(!iterator->second(pCaller, pFunction, pParms, pResult))
				{
					engineShouldRun = false; // Can't just do engineShouldRun = iterator->.. 
				}
			}

			if(!engineShouldRun)
			{
				// Tell the SDK not to run this function through the engine
				return false;
			}
		}

		// Run the function in the engine as normal
		return true;
	}

	extern "C" __declspec(dllexport) void LUAFUNC_AddStaticEngineHook(UFunction* pFunction, tProcessEventHook* funcHook)
	{
		CHookManager<tProcessEventHook>::tFuncNameHookPair hookPair = std::make_pair("LuaHook", funcHook);
		EngineHookManager->AddStaticHook(pFunction, hookPair);
	}

	extern "C" __declspec(dllexport) void LUAFUNC_RemoveStaticEngineHook(UFunction* pFunction)
	{
		EngineHookManager->RemoveStaticHook(pFunction, "LuaHook");
	}
}

