#include "LuaInterface/LuaManager.h"
#include "Logging/Logging.h"
#include "LuaInterface/CLuaUObject.h"
#include "LuaInterface/CLuaUObjectTable.h"

namespace LuaManager
{
	CLuaInterface* g_Lua;

	void Initialize()
	{
		// Create state and interface
		g_Lua = new CLuaInterface();

		// Register our classes
		CLuaUObject::Register(g_Lua);
		Logging::Log("[Lua] UObject registered\n");

		CLuaUObjectTable::Register(g_Lua);
		Logging::Log("[Lua] UObjectTable registered\n");

		// And we're done
		Logging::Log("[Lua] Lua initialized (" LUA_VERSION ")\n");
	}

	void Shutdown()
	{
		delete g_Lua;
	}

	
}