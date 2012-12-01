#include "LuaInterface/LuaManager.h"
#include "Logging/Logging.h"
//#include "LuaInterface/CLuaUObject.h"
//#include "LuaInterface/LUObjects.h"

namespace LuaManager
{
	CLuaInterface* g_Lua;

	void Initialize()
	{
		g_Lua = new CLuaInterface();
		Logging::Log("[Lua] Lua initialized (" LUA_VERSION ")\n");
	}

	void Shutdown()
	{
		delete g_Lua;
	}

	
}