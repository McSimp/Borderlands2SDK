#include "LuaInterface/CLuaUObjectTable.h"
#include "LuaInterface/CLuaUObject.h"
#include "Logging/Logging.h"

const char* CLuaUObjectTable::MetaName = "UObjectTable";
const int CLuaUObjectTable::MetaID = 101;
CLuaInterface* CLuaUObjectTable::m_Lua;

void CLuaUObjectTable::Register(CLuaInterface* pLua)
{
	m_Lua = pLua;

	CLuaObject* metaT = m_Lua->GetMetaTable(MetaName, MetaID);
		metaT->SetMember("__index", CLuaUObjectTable::Index);

	CLuaObject* ud = m_Lua->NewUserData(metaT);

	m_Lua->Global()->SetMember("UObjects", ud);
	
	ud->UnReference();
	metaT->UnReference();
}

int CLuaUObjectTable::Index(lua_State* L)
{
	Logging::Log("Entering index\n");
	// Currently I'm designing everything such that there is only ever 1 Lua state. This could change.
	int type = m_Lua->GetType(1);
	Logging::Log("Type = %i\n", type);
	m_Lua->CheckType(1, MetaID);
	
	Logging::Log("Type checked\n");
	UObject* pObject = NULL;

	if(m_Lua->IsType(2, Lua::TYPE_STRING))
	{
		Logging::Log("Arg is a string\n");
		pObject = FindObject(m_Lua->GetString(2));
	}
	else if(m_Lua->IsType(2, Lua::TYPE_NUMBER))
	{
		int index = m_Lua->GetInteger(2);
		Logging::Log("Arg is an int\n");
		if(index < UObject::GObjObjects()->Count)
		{
			pObject = UObject::GObjObjects()->Data[index];
		}
		else
		{
			m_Lua->LuaError("Index out of range", 2);
			return 0;
		}
	}
	else
	{
		m_Lua->LuaError("Index must be a string or number", 2);
		return 0;
	}

	if(!pObject)
	{
		m_Lua->Error("Failed to obtain UObject");
		return 0;
	}

	// If it's a function, we want to treat it as such
	if(pObject->IsA(UFunction::StaticClass()))
	{
		// TODO
		m_Lua->Error("UFunctions not implemented");
		return 0;
	}
	else
	{
		// Isn't this a problem with local variables?
		CLuaUObject luaObj(pObject);

		CLuaObject* metaT = m_Lua->GetMetaTable(CLuaUObject::MetaName, CLuaUObject::MetaID);
			m_Lua->PushUserData(metaT, &luaObj, CLuaUObject::MetaID);
		metaT->UnReference();
	}

	return 1;
}

UObject* CLuaUObjectTable::FindObject(const char* name)
{
	return UObject::FindObject<UObject>(name);
}
//#include "LuaInterface/LUObjects.h"
//#include "BL2SDK/BL2SDK.h"
//#include "Logging/Logging.h"
//
//namespace LuaInterface
//{
//	namespace LUObjects
//	{
//		UObject* FindObjectByFullName(const char* objectFullName)
//		{
//			if(objectFullName == NULL)
//			{
//				return NULL;
//			}
//
//			for (int i = 0; i < UObject::GObjObjects()->Count; i++) 
//			{ 
//				UObject* Object = UObject::GObjObjects()->Data[ i ]; 
//
//				if(!Object) 
//					continue;
//
//				if(!_stricmp(Object->GetFullName(), objectFullName)) 
//					return Object;
//			}
//
//			return NULL;
//		}
//
//		int UObjectsIndex(lua_State* L) 
//		{
//			UObject* pObject = NULL;
//			if(lua_type(L, 2) == LUA_TSTRING)
//			{
//				pObject = FindObjectByFullName(luaL_checkstring(L, 2));
//			}
//			else
//			{
//				int index = luaL_checkinteger(L, 2);
//				if(index < UObject::GObjObjects()->Count)
//				{
//					pObject = UObject::GObjObjects()->Data[index];
//				}
//				else
//				{
//					luaL_argcheck(L, 0, 2, "Index out of range.");
//				}
//			}
//
//			if(pObject)
//			{
//				if(pObject->IsA(UFunction::StaticClass()))
//				{
//					UFunctionData* pFunctionData = (UFunctionData*)lua_newuserdata(L, sizeof(*pFunctionData));
//					pFunctionData->pObject = pObject;
//					pFunctionData->pFunction = (UFunction*)pObject;
//
//					luaL_getmetatable(L, EngineUFunction);
//					lua_setmetatable(L, -2);
//				}
//				else
//				{
//					UObjectData* pObjectData = (UObjectData*)lua_newuserdata(L, sizeof(*pObjectData));
//					pObjectData->pObject = pObject;
//					pObjectData->pClass = pObject->Class;
//					pObjectData->pData = (char*)pObject;
//
//					luaL_getmetatable(L, EngineUObject);
//					lua_setmetatable(L, -2);
//				}
//			}
//			else
//			{
//				lua_pushnil(L);
//			}
//
//			return 1;
//		}
//
//		int UObjectsLen(lua_State* L) 
//		{
//			lua_pushinteger(L, UObject::GObjObjects()->Count);
//			return 1;
//		}
//
//		void Register(lua_State* L)
//		{
//			lua_pushstring(L, "UObjects");
//			lua_newuserdata(L, 1);
//			luaL_newmetatable(L, "BL2SDK.UObjects");
//			lua_pushstring(L, "__index");
//			lua_pushcfunction(L, UObjectsIndex);
//			lua_settable(L, -3);
//			lua_pushstring(L, "__len");
//			lua_pushcfunction(L, UObjectsLen);
//			lua_settable(L, -3);
//			lua_setmetatable(L, -2);
//			lua_settable(L, -3);
//		}
//	}
//}