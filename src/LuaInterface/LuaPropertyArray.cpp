#include "LuaInterface/LuaPropertyArray.h"

using LuaManager::g_Lua;

class LuaPropertyArrayUD
{
public:
	UProperty* property;
	UObject* object;

	LuaPropertyArrayUD(UProperty* prop, UObject* obj)
		: property(prop), object(obj)
	{}
};

namespace LuaPropertyArray
{
	int index(lua_State* L)
	{
		g_Lua->CheckType(1, MetaID);
		g_Lua->CheckType(2, Lua::TYPE_NUMBER);

		LuaPropertyArrayUD* data = (LuaPropertyArrayUD*)g_Lua->GetUserData(1);

		UProperty* property = data->property;
		
		int index = g_Lua->GetNumber(2) - 1; // Using Lua based indexing
		if(index >= property->ArrayDim || index < 0)
		{
			g_Lua->LuaError("Index out of range", 2);
			return 0;
		}
		else
		{
			property->PushToLua(data->object, index);
			return 1;
		}
	}

	int tostring(lua_State* L)
	{
		g_Lua->CheckType(1, MetaID);

		LuaPropertyArrayUD* data = (LuaPropertyArrayUD*)g_Lua->GetUserData(1);

		g_Lua->PushVA("%s: PropName = %s, ArrayDim = %d, ObjName = %s", MetaName, data->property->GetName(), data->property->ArrayDim, data->object->GetFullName());

		return 1;
	}

	int gc(lua_State* L)
	{
		g_Lua->CheckType(1, MetaID);
		LuaPropertyArrayUD* data = (LuaPropertyArrayUD*)g_Lua->GetUserData(1);
		delete data;
		return 0;
	}

	void Register()
	{
		CLuaObject* metaT = g_Lua->GetMetaTable(MetaName);
			metaT->SetMember("__index", index);
			metaT->SetMember("__tostring", tostring);
			metaT->SetMember("__gc", gc);
		metaT->UnReference();
	}

	void PushInstance(UProperty* property, UObject* object)
	{
		LuaPropertyArrayUD* data = new LuaPropertyArrayUD(property, object);

		CLuaObject* metaT = g_Lua->GetMetaTable(MetaName);
			g_Lua->PushUserData(metaT, data, MetaID);
		metaT->UnReference();
	}
}