#include "BL2SDK/GameHooks.h"
#include "BL2SDK/Logging.h"
#include "LuaInterface/Exports.h"

namespace GameHooks
{
	CHookManager* EngineHookManager;
	CHookManager* UnrealScriptHookManager;
	
	void Initialize()
	{
		EngineHookManager = new CHookManager("EngineHooks");
		Logging::LogF("[GameHooks] EngineHookManager = 0x%p\n", EngineHookManager);

		UnrealScriptHookManager = new CHookManager("UnrealScriptHooks");
		Logging::LogF("[GameHooks] UnrealScriptHookManager = 0x%p\n", UnrealScriptHookManager);
	}

	void Cleanup()
	{
		delete EngineHookManager;
		EngineHookManager = NULL;

		delete UnrealScriptHookManager;
		UnrealScriptHookManager = NULL;

		// TODO: Would it be best to do the detours in this?
	}

	bool ProcessEngineHooks(UObject* caller, UFunction* function, void* parms, void* result)
	{
		// Resolve any virtual hooks into static hooks
		EngineHookManager->ResolveVirtualHooks(function);

		// Call any static hooks that may exist
		CHookManager::tiStaticHooks iHooks = EngineHookManager->StaticHooks.find(function);
		if(iHooks != EngineHookManager->StaticHooks.end())
		{
			CHookManager::tHookMap hooks = iHooks->second;

			// TODO: Still not sure on best implementation here. Would it be better
			// just to stop every single next hook if one returns false?
			bool engineShouldRun = true;
			for(CHookManager::tiHookMap iterator = hooks.begin(); iterator != hooks.end(); iterator++)
			{
				// maps to std::string, void*, but we want to call a tProcessEventHook* instead
				if(!((tProcessEventHook*)iterator->second)(caller, function, parms, result))
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

	bool ProcessUnrealScriptHooks(UObject* caller, FFrame& stack, void* const result, UFunction* function)
	{
		// Resolve any virtual hooks into static hooks
		UnrealScriptHookManager->ResolveVirtualHooks(function);

		// Call any static hooks that may exist
		CHookManager::tiStaticHooks iHooks = UnrealScriptHookManager->StaticHooks.find(function);
		if(iHooks != UnrealScriptHookManager->StaticHooks.end())
		{
			CHookManager::tHookMap hooks = iHooks->second;

			// TODO: Still not sure on best implementation here. Would it be better
			// just to stop every single next hook if one returns false?
			bool engineShouldRun = true;
			for(CHookManager::tiHookMap iterator = hooks.begin(); iterator != hooks.end(); iterator++)
			{
				// maps to std::string, void*, but we want to call a tCallFunctionHook* instead
				if(!((tCallFunctionHook*)iterator->second)(caller, stack, result, function))
				{
					return false;
				}
			}
		}

		// Run the function in the engine as normal
		return true;
	}

	FFI_EXPORT void LUAFUNC_AddStaticEngineHook(UFunction* function, tProcessEventHook* funcHook)
	{
		CHookManager::tFuncNameHookPair hookPair = std::make_pair("LuaHook", funcHook);
		EngineHookManager->AddStaticHook(function, hookPair);
	}

	FFI_EXPORT void LUAFUNC_RemoveStaticEngineHook(UFunction* function)
	{
		EngineHookManager->RemoveStaticHook(function, "LuaHook");
	}

	FFI_EXPORT void LUAFUNC_AddStaticScriptHook(UFunction* function, tCallFunctionHook* funcHook)
	{
		CHookManager::tFuncNameHookPair hookPair = std::make_pair("LuaHook", funcHook);
		UnrealScriptHookManager->AddStaticHook(function, hookPair);
	}

	FFI_EXPORT void LUAFUNC_RemoveStaticScriptHook(UFunction* function)
	{
		UnrealScriptHookManager->RemoveStaticHook(function, "LuaHook");
	}
}

