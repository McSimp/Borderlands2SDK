#include "LuaInterface/LuaUObjectTable.h"
#include "LuaInterface/LuaUObject.h"
#include "Logging/Logging.h"

using LuaManager::g_Lua;

namespace LuaUObjectTable
{
	int index(lua_State* L)
	{
		// Currently I'm designing everything such that there is only ever 1 Lua state. This could change.
		g_Lua->CheckType(1, MetaID);

		UObject* pObject = NULL;

		if(g_Lua->IsType(2, Lua::TYPE_STRING))
		{
			pObject = UObject::FindObject<UObject>(g_Lua->GetString(2));
		}
		else if(g_Lua->IsType(2, Lua::TYPE_NUMBER))
		{
			int index = g_Lua->GetInteger(2);
			if(index < UObject::GObjObjects()->Count && index >= 0)
			{
				pObject = UObject::GObjObjects()->Data[index];
			}
			else
			{
				g_Lua->LuaError("Index out of range", 2);
				return 0;
			}
		}
		else
		{
			g_Lua->LuaError("Index must be a string or number", 2);
			return 0;
		}

		if(!pObject)
		{
			Logging::Log("[Lua] Warning: Failed to obtain UObject\n");
			g_Lua->PushNil();
			return 1;
		}

		// If it's a function, we want to treat it as such
		if(pObject->IsA(UFunction::StaticClass()))
		{
			// TODO
			Logging::Log("[Lua] Warning: UFunctions not implemented\n");
			g_Lua->PushNil();
			return 1;
		}
		else
		{
			LuaUObject::PushInstance(pObject);
		}

		return 1;
	}

	int length(lua_State* L)
	{
		g_Lua->Push(UObject::GObjObjects()->Count);
		return 1;
	}

	void Register()
	{
		CLuaObject* metaT = g_Lua->GetMetaTable(MetaName);
		metaT->SetMember("__index", index);
		metaT->SetMember("__len", length);

		CLuaObject* ud = g_Lua->NewUserData(metaT);
		ud->SetUserData(NULL, MetaID);

		g_Lua->Global()->SetMember("UObjects", ud);
	
		ud->UnReference();
		metaT->UnReference();
	}
}




