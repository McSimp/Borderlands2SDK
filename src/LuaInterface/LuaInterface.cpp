#include "LuaInterface/LuaInterface.h"
#include "Logging/Logging.h"

#ifdef _DEBUG
#pragma comment (lib, "Lua521Libd.lib")
#else
#pragma comment (lib, "Lua521Lib.lib")
#endif

namespace LuaInterface 
{
	lua_State* L = NULL;
	lua_State* Lua()
	{
		return L;
	}

	int luaF_Log(lua_State* L) 
	{
		Logging::Log("%s", (char*)luaL_checkstring(L, 1));
		return 0;
	}

	static const luaL_Reg SDKLib[] = 
	{
		{"Log", luaF_Log},
		{NULL, NULL}
	};

	int luaopen_BL2SDK(lua_State* L)
	{
		luaL_newlib(L, SDKLib);
		return 1;
	}

	// We want Lua to only be in the game's main thread, so only call from ProcessEvent
	void Initialize()
	{
		if(!L)
		{
			L = luaL_newstate();
			luaL_openlibs(L);

			// Add in our BL2SDK module
			luaL_requiref(L, "BL2SDK", luaopen_BL2SDK, 1);
			lua_pop(L, 1);

			lua_gc(L, LUA_GCRESTART, 0);
		}
	}

	void Shutdown()
	{
		if(L)
		{
			lua_close(L);
			L = NULL;
		}
	}
}