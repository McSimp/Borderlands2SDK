#include "LuaInterface/LuaManager.h"
#include "Logging/Logging.h"
#include "Commands/ConCommand.h"

namespace LuaManager
{
	CLuaInterface* g_Lua;

	void Initialize()
	{
		// Create state and interface
		g_Lua = new CLuaInterface();

		// Setup everything on the Lua side
		if(g_Lua->DoFile("includes\\init.lua") != 0) // Means it failed, weird right
		{
			Logging::Log("[Lua] Failed to initialize Lua modules\n");
		}

		// And we're done
		Logging::Log("[Lua] Lua initialized (" LUA_VERSION ")\n");
	}

	void Shutdown()
	{
		delete g_Lua;
	}
}

CON_COMMAND(ResetLua)
{
	LuaManager::Shutdown();
	LuaManager::Initialize();
	Logging::Log("Lua Restarted\n");
}
