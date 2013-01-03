#include "LuaInterface/LuaTArray.h"
#include "Logging/Logging.h"

using LuaManager::g_Lua;

struct TArrayData 
{ 
	unsigned char* Data; 
	int Count; 
	int Max;
}; 


class LuaTArrayUD
{
public:
	UProperty* innerProperty;
	TArrayData* array;

	LuaTArrayUD(UProperty* prop, void* data)
		: innerProperty(prop), array((TArrayData*)data)
	{}
};


namespace LuaTArray
{
	int index(lua_State* L)
	{
		g_Lua->CheckType(1, MetaID);
		g_Lua->CheckType(2, Lua::TYPE_NUMBER);

		LuaTArrayUD* ud = (LuaTArrayUD*)g_Lua->GetUserData(1);

		TArrayData* array = ud->array;
		int index = g_Lua->GetNumber(2) - 1; // Using Lua based indexing
		if(index >= array->Count || index < 0)
		{
			g_Lua->LuaError("Index out of range", 2);
			return 0;
		}
		else
		{
			void* data = (void*)(array->Data + (ud->innerProperty->ElementSize * index));
			ud->innerProperty->PushToLua(data);
			return 1;
		}
	}

	int tostring(lua_State* L)
	{
		g_Lua->CheckType(1, MetaID);

		LuaTArrayUD* ud = (LuaTArrayUD*)g_Lua->GetUserData(1);

		g_Lua->PushVA("%s: Type = %s, Count = %d, Max = %d, Ptr = 0x%X", MetaName, ud->innerProperty->Class->GetFullName(), ud->array->Count, ud->array->Max, ud->array);

		return 1;
	}

	int gc(lua_State* L)
	{
		g_Lua->CheckType(1, MetaID);
		LuaTArrayUD* data = (LuaTArrayUD*)g_Lua->GetUserData(1);
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

	void PushInstance(UProperty* prop, void* data)
	{
		LuaTArrayUD* ud = new LuaTArrayUD(prop, data);

		CLuaObject* metaT = g_Lua->GetMetaTable(MetaName);
			g_Lua->PushUserData(metaT, ud, MetaID);
		metaT->UnReference();
	}
}