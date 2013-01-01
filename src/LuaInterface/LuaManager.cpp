#include "LuaInterface/LuaManager.h"
#include "Logging/Logging.h"
#include "LuaInterface/LuaUObject.h"
#include "LuaInterface/LuaUObjectTable.h"
#include "LuaInterface/LuaPropertyArray.h"

namespace LuaManager
{
	CLuaInterface* g_Lua;

	void Initialize()
	{
		// Create state and interface
		g_Lua = new CLuaInterface();

		// Register our classes
		LuaUObject::Register();
		Logging::Log("[Lua] UObject registered\n");

		LuaUObjectTable::Register();
		Logging::Log("[Lua] UObjectTable registered\n");

		LuaPropertyArray::Register();
		Logging::Log("[Lua] PropertyArray registered\n");

		// And we're done
		Logging::Log("[Lua] Lua initialized (" LUA_VERSION ")\n");
	}

	void Shutdown()
	{
		delete g_Lua;
	}
}
