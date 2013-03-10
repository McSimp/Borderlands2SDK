#include "BL2SDK/EngineHooks.h"
#include "BL2SDK/Logging.h"
#include <map>

namespace EngineHooks
{
	typedef std::map<std::string, tProcessEventHook*> tHookMap;
	typedef tHookMap::iterator tiHookMap;
	typedef std::map<std::string, tHookMap>::iterator tiVirtualHooks;
	typedef std::map<UFunction*, tHookMap>::iterator tiStaticHooks;
	typedef std::pair<std::string, tProcessEventHook*> tFuncNameHookPair;

	std::map<std::string, tHookMap> VirtualHooks;
	std::map<UFunction*, tHookMap> StaticHooks;

	tHookMap* GetVirtualHookTable(const std::string& funcName)
	{
		tiVirtualHooks iHooks = VirtualHooks.find(funcName);
		if(iHooks != VirtualHooks.end())
		{
			return &iHooks->second;
		}

		return NULL;
	}

	tHookMap* GetStaticHookTable(UFunction* pFunction)
	{
		tiStaticHooks iHooks = StaticHooks.find(pFunction);
		if(iHooks != StaticHooks.end())
		{
			return &iHooks->second;
		}

		return NULL;
	}

	void AddVirtualHook(const std::string& funcName, tFuncNameHookPair& hookPair)
	{
		tHookMap* vHookMap = GetVirtualHookTable(funcName);
		if(vHookMap == NULL)
		{
			// There are no other virtual hooks so we need to create the table for it
			tHookMap newMap;
			newMap.insert(hookPair); // TODO: Dereference pointer?
			VirtualHooks.insert(std::make_pair(funcName, newMap));
		}
		else
		{
			// Otherwise it's fine, add it into the existing table
			vHookMap->insert(hookPair); // TODO: Dereference pointer?
		}
	}

	void AddStaticHook(UFunction* pFunction, tFuncNameHookPair& hookPair)
	{
		tHookMap* hookMap = GetStaticHookTable(pFunction);
		if(hookMap == NULL)
		{
			// There are no other hooks so we need to create the table for it
			tHookMap newMap;
			newMap.insert(hookPair); // TODO: Dereference pointer?
			StaticHooks.insert(std::make_pair(pFunction, newMap));
		}
		else
		{
			// Otherwise it's fine, add it into the existing table
			hookMap->insert(hookPair); // TODO: Dereference pointer?
		}
	}

	bool RemoveFromTable(tHookMap& hookTable, const std::string& funcName, const std::string& hookName)
	{
		// Remove it and ensure that it actually got removed
		int sizeDiff = hookTable.size();
		hookTable.erase(hookName);
		sizeDiff -= hookTable.size();

		if(sizeDiff == 0)
		{
			Logging::LogF("[Engine Hooks] Failed to remove hook \"%s\" for function \"%s\"\n", hookName.c_str(), funcName.c_str());
			return false;
		}

		Logging::LogF("[Engine Hooks] Hook \"%s\" removed for function \"%s\" successfully\n", hookName.c_str(), funcName.c_str());
		return true;
	}

	bool RemoveVirtualHook(const std::string& funcName, const std::string& hookName)
	{
		tHookMap* hookTable = GetVirtualHookTable(funcName);
		if(hookTable == NULL)
		{
			Logging::LogF("[Engine Hooks] ERROR: Failed to remove virtual hook \"%s\" for \"%s\"\n", hookName.c_str(), funcName);
			return false;
		}

		return RemoveFromTable(*hookTable, funcName, hookName);
	}

	bool RemoveStaticHook(UFunction* pFunction, const std::string& hookName)
	{
		// Since we are getting a UFunction pointer, we don't need to check virtual hooks
		tHookMap* hookTable = GetStaticHookTable(pFunction);
		if(hookTable == NULL)
		{
			Logging::LogF("[Engine Hooks] ERROR: Failed to remove static hook \"%s\" for \"%s\"\n", hookName.c_str(), pFunction->GetFullName());
			return false;
		}

		return RemoveFromTable(*hookTable, pFunction->GetFullName(), hookName);
	}

	bool ProcessHooks(UObject* pCaller, UFunction* pFunction, void* pParms, void* pResult)
	{
		// Resolve any virtual hooks into static hooks
		if(VirtualHooks.size() > 0)
		{
			//std::string funcName = GetFuncName(pFunction); TODO: Use this instead of the ugly other thing
			std::string funcName = pFunction->GetFullName();

			tiVirtualHooks iVHooks = VirtualHooks.find(funcName);
			if(iVHooks != VirtualHooks.end())
			{
				// Insert this map into the static hooks map
				int size = iVHooks->second.size();
				StaticHooks.insert(std::make_pair(pFunction, iVHooks->second));
				VirtualHooks.erase(iVHooks);
				Logging::LogF("[Engine Hooks] Function pointer found for \"%s\", added map with %i elements to static hooks map\n", funcName.c_str(), size);
			}
		}

		// Call any static hooks that may exist
		tiStaticHooks iHooks = StaticHooks.find(pFunction);
		if(iHooks != StaticHooks.end())
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

	void Register(const std::string& funcName, const std::string& hookName, tProcessEventHook* funcHook)
	{
		// Create pair to insert
		tFuncNameHookPair hookPair = std::make_pair(hookName, funcHook);

		// Find func
		UFunction* pFunction = UObject::FindObject<UFunction>(funcName.c_str());
		if(pFunction == NULL)
		{
			// The function was not found, so we need to create a virtual hook for it
			AddVirtualHook(funcName, hookPair);

			Logging::LogF("[Engine Hooks] Hook \"%s\" added as virtual hook for \"%s\"\n", hookName.c_str(), funcName.c_str());
		}
		else
		{
			// The function WAS found, so we can just hook it straight away
			AddStaticHook(pFunction, hookPair);

			Logging::LogF("[Engine Hooks] Hook \"%s\" added as static hook for \"%s\"\n", hookName.c_str(), funcName.c_str());
		}
	}

	bool Remove(const std::string& funcName, const std::string& hookName)
	{
		UFunction* pFunction = UObject::FindObject<UFunction>(funcName.c_str());
		if(pFunction == NULL)
		{
			// Function wasn't found, so virtual hook removal time!
			return RemoveVirtualHook(funcName, hookName);
		}
		else
		{
			// We did find it, so remove the static hook
			// TODO: WARNING. MAJOR PROBLEM HERE.
			// If a virtual hook has been created because the UFunction didn't exist,
			// but then the function is created but NOT CALLED, then the hook system
			// will keep the virtual hook, and we won't delete it here.
			return RemoveStaticHook(pFunction, hookName);
		}
	}

	extern "C" __declspec(dllexport) int LUAFUNC_HookFunction(const char* funcName, tProcessEventHook* funcHook)
	{
		Register(funcName, "LuaHook", funcHook);
		return 1;
	}

	extern "C" __declspec(dllexport) int LUAFUNC_RemoveHook(const char* funcName)
	{
		Remove(funcName, "LuaHook");
		return 1;
	}
}

