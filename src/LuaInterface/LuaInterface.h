#ifndef LUAINTERFACE_H
#define LUAINTERFACE_H

#include "Lua/lua.hpp"

namespace LuaInterface 
{
	lua_State* Lua();
	void Initialize();
	void Shutdown();
}

#endif