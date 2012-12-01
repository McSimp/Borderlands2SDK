#ifndef LUAMANAGER_H
#define LUAMANAGER_H
#include "LuaInterface/CLuaInterface.h"

namespace LuaManager 
{
	void Initialize();
	void Shutdown();

	extern CLuaInterface* g_Lua;
}

#endif