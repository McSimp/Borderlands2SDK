#include "BL2SDK/BL2SDK.h"
#include "Logging/Logging.h"
#include "Commands/ConCommand.h"
#include "LuaInterface/LuaManager.h"

#include <iterator>
#include <sstream>

using LuaManager::g_Lua;

CON_COMMAND(lua_run_cl)
{
	std::stringstream ss;
	std::copy(args.begin()+1, args.end(), std::ostream_iterator<std::string>(ss, " "));
	std::string result = ss.str(); // There's a trailing space but lua shouldn't give a shit

	g_Lua->RunString(result.c_str());
}

CON_COMMAND(lua_openscript_cl)
{
	/*
	std::stringstream ss;
	std::copy(args.begin()+1, args.end(), std::ostream_iterator<std::string>(ss, " "));
	std::string result = ss.str(); // There's a trailing space but lua shouldn't give a shit

	if(Lua())
	{
		int status = luaL_loadfile(Lua(), result.c_str());
		if(status)
		{
			Logging::Log("[Lua] Error: %s\n", lua_tostring(Lua(), -1));
			return;
		}

		status = lua_pcall(Lua(), 0, LUA_MULTRET, 0);
		if(status)
		{
			Logging::Log("[Lua] Error: %s\n", lua_tostring(Lua(), -1));
			return;
		}
	}
	else
	{
		Logging::Log("[Lua] Error: Lua state not initialized\n");
	}
	*/
}