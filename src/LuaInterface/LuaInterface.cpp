#include "LuaInterface/LuaInterface.h"
#include "Logging/Logging.h"
#include "LuaInterface/LUObject.h"
#include "LuaInterface/LUObjects.h"

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
			//lua_pop(L, 1);

			// Register shit
			Logging::Log("Registering LUObject\n");
			LUObject::Register(L);
			Logging::Log("Registering LUObjects\n");
			LUObjects::Register(L);
			lua_gc(L, LUA_GCRESTART, 0);
			/*
			int status = luaL_loadfile(L, "lua/includes/modules/concommand.lua");
			if(status)
			{
				Logging::Log("[Lua] Error loading concommand module: %s\n", lua_tostring(L, -1));
				return;
			}

			status = lua_pcall(L, 0, LUA_MULTRET, 0);
			if(status)
			{
				Logging::Log("[Lua] Error loading concommand module: %s\n", lua_tostring(L, -1));
				return;
			}
			*/
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

	void StackDump(lua_State* L)
	{
		int i=lua_gettop(L);
		Logging::Log(" ----------------  Stack Dump ----------------\n" );
		while(i) 
		{
			int t = lua_type(L, i);
			switch (t) {
			case LUA_TSTRING:
				Logging::Log("%d:`%s'\n", i, lua_tostring(L, i));
				break;
			case LUA_TBOOLEAN:
				Logging::Log("%d: %s\n",i,lua_toboolean(L, i) ? "true" : "false");
				break;
			case LUA_TNUMBER:
				Logging::Log("%d: %g\n",  i, lua_tonumber(L, i));
				break;
			default: 
				Logging::Log("%d: %s\n", i, lua_typename(L, t));
				break;
			}
			i--;
		}
		Logging::Log("--------------- Stack Dump Finished ---------------\n" );
	}
}