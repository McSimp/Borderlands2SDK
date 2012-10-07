#include "LuaInterface/LUObjects.h"
#include "BL2SDK/BL2SDK.h"
#include "Logging/Logging.h"

namespace LuaInterface
{
	namespace LUObjects
	{
		UObject* FindObjectByFullName(const char* objectFullName)
		{
			if(objectFullName == NULL)
			{
				return NULL;
			}

			for (int i = 0; i < UObject::GObjObjects()->Count; i++) 
			{ 
				UObject* Object = UObject::GObjObjects()->Data[ i ]; 

				if(!Object) 
					continue;

				if(!_stricmp(Object->GetFullName(), objectFullName)) 
					return Object;
			}

			return NULL;
		}

		int UObjectsIndex(lua_State* L) 
		{
			UObject* pObject = NULL;
			if(lua_type(L, 2) == LUA_TSTRING)
			{
				pObject = FindObjectByFullName(luaL_checkstring(L, 2));
			}
			else
			{
				int index = luaL_checkinteger(L, 2);
				if(index < UObject::GObjObjects()->Count)
				{
					pObject = UObject::GObjObjects()->Data[index];
				}
				else
				{
					luaL_argcheck(L, 0, 2, "Index out of range.");
				}
			}

			if(pObject)
			{
				if(pObject->IsA(UFunction::StaticClass()))
				{
					UFunctionData* pFunctionData = (UFunctionData*)lua_newuserdata(L, sizeof(*pFunctionData));
					pFunctionData->pObject = pObject;
					pFunctionData->pFunction = (UFunction*)pObject;

					luaL_getmetatable(L, EngineUFunction);
					lua_setmetatable(L, -2);
				}
				else
				{
					UObjectData* pObjectData = (UObjectData*)lua_newuserdata(L, sizeof(*pObjectData));
					pObjectData->pObject = pObject;
					pObjectData->pClass = pObject->Class;
					pObjectData->pData = (char*)pObject;

					luaL_getmetatable(L, EngineUObject);
					lua_setmetatable(L, -2);
				}
			}
			else
			{
				lua_pushnil(L);
			}

			return 1;
		}

		int UObjectsLen(lua_State* L) 
		{
			lua_pushinteger(L, UObject::GObjObjects()->Count);
			return 1;
		}

		void Register(lua_State* L)
		{
			lua_pushstring(L, "UObjects");
			lua_newuserdata(L, 1);
			luaL_newmetatable(L, "BL2SDK.UObjects");
			lua_pushstring(L, "__index");
			lua_pushcfunction(L, UObjectsIndex);
			lua_settable(L, -3);
			lua_pushstring(L, "__len");
			lua_pushcfunction(L, UObjectsLen);
			lua_settable(L, -3);
			lua_setmetatable(L, -2);
			lua_settable(L, -3);
		}
	}
}