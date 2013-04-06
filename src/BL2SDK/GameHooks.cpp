#include "BL2SDK/GameHooks.h"
#include "BL2SDK/Logging.h"

namespace GameHooks
{
	CHookManager* EngineHookManager = new CHookManager();
	CHookManager* UnrealScriptHookManager = new CHookManager();
	
	bool ProcessEngineHooks(UObject* pCaller, UFunction* pFunction, void* pParms, void* pResult)
	{
		// Resolve any virtual hooks into static hooks
		if(EngineHookManager->VirtualHooks.size() > 0)
		{
			//std::string funcName = GetFuncName(pFunction); TODO: Use this instead of the ugly other thing
			std::string funcName = pFunction->GetFullName();

			tiVirtualHooks iVHooks = EngineHookManager->VirtualHooks.find(funcName);
			if(iVHooks != EngineHookManager->VirtualHooks.end())
			{
				// Insert this map into the static hooks map
				int size = iVHooks->second.size();
				EngineHookManager->StaticHooks.insert(std::make_pair(pFunction, iVHooks->second));
				EngineHookManager->VirtualHooks.erase(iVHooks);
				Logging::LogF("[Engine Hooks] Function pointer found for \"%s\", added map with %i elements to static hooks map\n", funcName.c_str(), size);
			}
		}

		// Call any static hooks that may exist
		tiStaticHooks iHooks = EngineHookManager->StaticHooks.find(pFunction);
		if(iHooks != EngineHookManager->StaticHooks.end())
		{
			tHookMap hooks = iHooks->second;

			// TODO: Still not sure on best implementation here. Would it be better
			// just to stop every single next hook if one returns false?
			bool engineShouldRun = true;
			for(tiHookMap iterator = hooks.begin(); iterator != hooks.end(); iterator++)
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

	/*
	extern "C" __declspec(dllexport) void LUAFUNC_AddHook(const char* funcName, tProcessEventHook* funcHook)
	{
		Register(funcName, "LuaHook", funcHook);
	}

	extern "C" __declspec(dllexport) void LUAFUNC_RemoveHook(const char* funcName)
	{
		Remove(funcName, "LuaHook");
	}

	extern "C" __declspec(dllexport) void LUAFUNC_AddStaticHook(UFunction* pFunction, tProcessEventHook* funcHook)
	{
		tFuncNameHookPair hookPair = std::make_pair("LuaHook", funcHook);
		AddStaticHook(pFunction, hookPair);
	}

	extern "C" __declspec(dllexport) void LUAFUNC_RemoveStaticHook(UFunction* pFunction)
	{
		RemoveStaticHook(pFunction, "LuaHook");
	}
	*/
}

