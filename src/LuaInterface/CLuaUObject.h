#ifndef CLUAUOBJECT_H
#define CLUAUOBJECT_H

#include "LuaInterface/CLuaInterface.h"
#include "BL2SDK/BL2SDK.h"

class CLuaUObject
{
	UObject* m_pObject;
	static CLuaInterface* m_Lua;

	UProperty* FindProperty(const char* propertyName);
	void PushProperty(UProperty* pProperty);

public:
	static const char* MetaName;
	static const int MetaID;

	CLuaUObject(UObject* pObject);

	static void Register(CLuaInterface* pLua);
	static int Index(lua_State* L);
	static int ToString(lua_State* L);
	static int GC(lua_State* L);
};

#endif