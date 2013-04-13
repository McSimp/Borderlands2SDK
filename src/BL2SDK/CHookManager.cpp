#include "BL2SDK/CHookManager.h"
#include "BL2SDK/Logging.h"

CHookManager::tHookMap* CHookManager::GetVirtualHookTable(const std::string& funcName)
{
	tiVirtualHooks iHooks = VirtualHooks.find(funcName);
	if(iHooks != VirtualHooks.end())
	{
		return &iHooks->second;
	}

	return NULL;
}

CHookManager::tHookMap* CHookManager::GetStaticHookTable(UFunction* pFunction)
{
	tiStaticHooks iHooks = StaticHooks.find(pFunction);
	if(iHooks != StaticHooks.end())
	{
		return &iHooks->second;
	}

	return NULL;
}

void CHookManager::AddVirtualHook(const std::string& funcName, const tFuncNameHookPair& hookPair)
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

	Logging::LogF("[CHookManager] (%s) Hook \"%s\" added as virtual hook for \"%s\"\n", this->DebugName.c_str(), hookPair.first.c_str(), funcName.c_str());
}

void CHookManager::AddStaticHook(UFunction* pFunction, const tFuncNameHookPair& hookPair)
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

	Logging::LogF("[CHookManager] (%s) Hook \"%s\" added as static hook for \"%s\"\n", this->DebugName.c_str(), hookPair.first.c_str(), pFunction->GetName());
}

bool CHookManager::RemoveFromTable(tHookMap& hookTable, const std::string& funcName, const std::string& hookName)
{
	// Remove it and ensure that it actually got removed
	int sizeDiff = hookTable.size();
	hookTable.erase(hookName);
	sizeDiff -= hookTable.size();

	if(sizeDiff == 0)
	{
		Logging::LogF("[CHookManager] (%s) Failed to remove hook \"%s\" for function \"%s\"\n", this->DebugName.c_str(), hookName.c_str(), funcName.c_str());
		return false;
	}

	Logging::LogF("[CHookManager] (%s) Hook \"%s\" removed for function \"%s\" successfully\n", this->DebugName.c_str(), hookName.c_str(), funcName.c_str());
	return true;
}

void CHookManager::Register(const std::string& funcName, const std::string& hookName, void* funcHook)
{
	// Create pair to insert
	tFuncNameHookPair hookPair = std::make_pair(hookName, funcHook);
	
	// Find func
	UFunction* pFunction = UObject::FindObject<UFunction>(funcName.c_str());
	if(pFunction == NULL)
	{
		// The function was not found, so we need to create a virtual hook for it
		AddVirtualHook(funcName, hookPair);
	}
	else
	{
		// The function WAS found, so we can just hook it straight away
		AddStaticHook(pFunction, hookPair);
	}
}

bool CHookManager::Remove(const std::string& funcName, const std::string& hookName)
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

bool CHookManager::RemoveVirtualHook(const std::string& funcName, const std::string& hookName)
{
	tHookMap* hookTable = GetVirtualHookTable(funcName);
	if(hookTable == NULL)
	{
		Logging::LogF("[CHookManager] (%s) ERROR: Failed to remove virtual hook \"%s\" for \"%s\"\n", this->DebugName.c_str(), hookName.c_str(), funcName);
		return false;
	}

	return RemoveFromTable(*hookTable, funcName, hookName);
}

bool CHookManager::RemoveStaticHook(UFunction* pFunction, const std::string& hookName)
{
	// Since we are getting a UFunction pointer, we don't need to check virtual hooks
	tHookMap* hookTable = GetStaticHookTable(pFunction);
	if(hookTable == NULL)
	{
		Logging::LogF("[CHookManager] (%s) ERROR: Failed to remove static hook \"%s\" for \"%s\"\n", this->DebugName.c_str(), hookName.c_str(), pFunction->GetFullName());
		return false;
	}

	return RemoveFromTable(*hookTable, pFunction->GetFullName(), hookName);
}

void CHookManager::ResolveVirtualHooks(UFunction* pFunction)
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
			Logging::LogF("[CHookManager] (%s) Function pointer found for \"%s\", added map with %i elements to static hooks map\n", this->DebugName.c_str(), funcName.c_str(), size);
		}
	}
}
