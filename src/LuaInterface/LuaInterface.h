#ifndef LUAINTERFACE_H
#define LUAINTERFACE_H

#include "BL2SDK/BL2SDK.h"
#include "Lua/lua.hpp"

#define EngineUObject "BL2SDK.UObject"
#define EngineUFunction "BL2SDK.UFunction"
#define EngineUProperty "BL2SDK.UProperty"
#define NO_INDEX 0x7FFFFFFF

namespace LuaInterface 
{
	struct UFunctionData
	{
		UObject*   pObject;
		UFunction* pFunction;
	};

	struct UObjectData
	{
		UObject*   pObject;
		UClass*    pClass;
		char*      pData;
	};

	struct UObjectProp
	{
		UObject*   pObject;
		UProperty* pProperty;
		char*      pData;
	};

	lua_State* Lua();
	void Initialize();
	void Shutdown();
	void StackDump(lua_State* L);
}

#endif