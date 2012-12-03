#ifndef CLUAUOBJECTSTABLE_H
#define CLUAUOBJECTSTABLE_H

#include "LuaInterface/CLuaInterface.h"
#include "BL2SDK/BL2SDK.h"

class CLuaUObjectTable
{
	static CLuaInterface* m_Lua;

public:
	static const char* MetaName;
	static const int MetaID;

	static void Register(CLuaInterface* pLua);
	static int Index(lua_State* L);
	static int Length(lua_State* L);
	static UObject* FindObject(const char* name);
};

#endif