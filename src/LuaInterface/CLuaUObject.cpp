#include "LuaInterface/CLuaUObject.h"
#include "BL2SDK/BL2SDK.h"
#include "LuaInterface/CLuaInterface.h"

#include <map>
#include <string>

namespace LuaInterface
{
	class CLuaUObject
	{
		UObject* m_pObject;
		CLuaInterface* m_pLua;
		//std::map<std::string, UProperty*> m_propCache; Benchmarking needed

		UProperty* FindProperty(const char* propertyName)
		{
			// Basic algorithm:
			// (-> Resolve the property name from Lua to an FName for faster lookup)
			// ^ On second thoughts, this would probably result in more string comparisons and be SLOWER.
			// -> Start with the outermost class. 
			// -> Go through all of the fields in this class to see if it matches the one we want
			// -> If no match found, repeat with the next inherited class.
			// -> If we reach the highest level and we haven't found a match, we failed.
			
			UProperty* pProperty = NULL;
			UClass* pCurClass = m_pObject->Class;

			while(pCurClass && !pProperty) // While there are still super classes and we haven't found the property
			{
				UField* pField = pCurClass->Children;
				while(pField) // Check all of this class' fields to see if it's the property we want
				{
					if(pField->IsA(UFunction::StaticClass()) || pField->IsA(UProperty::StaticClass())) // Is it a function/property?
					{
						if(!strcmp(propertyName, pField->Name.GetName()))
						{
							pProperty = (UProperty*)pField; // UFunction technically doesn't fit this, but good enough
							break;
						}
					}

					pField = pField->Next;
				}

				pCurClass = (UClass*)pCurClass->SuperField; // The property wasn't found in the outer class, go to the next one in.
			}

			return pProperty;
		}

		void PushProperty(UProperty* pProperty)
		{
			// Property types:
			// UByteProperty, UIntProperty, UFloatProperty, UBoolProperty, UStrProperty, UNameProperty
			// UDelegateProperty, UObjectProperty, UClassProperty, UInterfaceProperty, UStructProperty
			// UArrayProperty, UMapProperty
			// and UFunction

			if(pProperty->IsA(UFunction::StaticClass()))
			{

			}
		}
	};
}

	/*
	namespace LUObject
	{

		void GetProperty(lua_State* L, UObject* pObject, UProperty* pProperty, char* pData, int index)
		{
			if(pProperty->IsA(UFunction::StaticClass()))
			{
				// It's a function, so return a function userdatum
				UFunctionData* pFunctionData = (UFunctionData*)lua_newuserdata(L, sizeof(*pFunctionData));
				pFunctionData->pObject = pObject;
				pFunctionData->pFunction = (UFunction*)pProperty;

				luaL_getmetatable(L, EngineUFunction);
				lua_setmetatable(L, -2);
				return;
			}

			if ((index == NO_INDEX) && ((pProperty->ArrayDim > 1) || 
				pProperty->IsA(UArrayProperty::StaticClass())))
			{
				UObjectProp* pObjectProp = (UObjectProp*)lua_newuserdata(L, sizeof(*pObjectProp));
				pObjectProp->pObject = pObject;
				pObjectProp->pProperty = pProperty;
				pObjectProp->pData = pData;

				luaL_getmetatable(L, EngineUProperty);
				lua_setmetatable(L, -2);
				return;
			}

			if ((index != NO_INDEX) && (pProperty->ArrayDim == 1))
			{
				luaL_argcheck(L, 0, 2, "Property cannot be indexed.");
				return;
			}

			if(index == NO_INDEX)
				index = 0;

			if((index < 0) || ((unsigned long)index >= pProperty->ArrayDim))
			{
				luaL_argcheck(L, 0, 2, "Index out of range.");
				return;
			}

			if (pProperty->IsA(UByteProperty::StaticClass()))
			{
				int value = *(unsigned char*)(pData + pProperty->Offset +
					(pProperty->ElementSize * index));
				lua_pushinteger(L, value);
			}
			else if (pProperty->IsA(UIntProperty::StaticClass()))
			{
				int value = *(int*)(pData + pProperty->Offset +
					(pProperty->ElementSize * index));
				lua_pushinteger(L, value);
			}
			else if (pProperty->IsA(UFloatProperty::StaticClass()))
			{
				float value = *(float*)(pData + pProperty->Offset +
					(pProperty->ElementSize * index));
				lua_pushnumber(L, value);
			}
			// BoolProperty
			else if (pProperty->IsA(UStrProperty::StaticClass()))
			{
				FString* value = (FString*)(pData + pProperty->Offset +
					(pProperty->ElementSize * index));
				if(value->Data)
				{
					char* pName = new char[value->Count];
					sprintf(pName, "%S", value->Data);
					lua_pushstring(L, pName);
					delete[] pName;
				}
				else
				{
					lua_pushnil(L);
				}
			}
			else if(pProperty->IsA(UNameProperty::StaticClass()))
			{
				FName value = *(FName*)(pData + pProperty->Offset +
					(pProperty->ElementSize * index));
				lua_pushstring(L, value.GetName());
			}
			// DelegateProperty
			else if(pProperty->IsA(UObjectProperty::StaticClass()) ||
				pProperty->IsA(UClassProperty::StaticClass()))
			{
				UObject* pValue = *(UObject **)(pData + pProperty->Offset +
					(pProperty->ElementSize * index));

				if(pValue)
				{
					UObjectData* pObjectData = (UObjectData*)lua_newuserdata(L, sizeof(*pObjectData));
					pObjectData->pObject = pValue;
					pObjectData->pClass = pValue->Class;
					pObjectData->pData = (char*)pValue;
					
					luaL_getmetatable(L, EngineUObject);
					lua_setmetatable(L, -2);
				}
				else
				{
					lua_pushnil(L);
				}
			}
			// InterfaceProperty (Probably same as Class/Object?)
			else if(pProperty->IsA(UStructProperty::StaticClass()))
			{
				UObjectData* pObjectData = (UObjectData*)lua_newuserdata(L, sizeof(*pObjectData));
				pObjectData->pObject = pObject;
				pObjectData->pClass = (UClass*)((UStructProperty*)pProperty)->Struct; // TODO: Fix maybe?
				pObjectData->pData = pData + pProperty->Offset +
					(pProperty->ElementSize * index);

				luaL_getmetatable(L, EngineUObject);
				lua_setmetatable(L, -2);
			}
			else if(pProperty->IsA(UArrayProperty::StaticClass()))
			{
				TArray<char>* pValue = (TArray<char>*)(pData + pProperty->Offset); // void?
				if(index >= pValue->Count)
				{
					luaL_argcheck(L, 0, 2, "Index out of range.");
					return;
				}

				pProperty = ((UArrayProperty*)pProperty)->Inner;
				GetProperty(L, pObject, pProperty, (char*)((DWORD)pValue->Data + 
					(index * pProperty->ElementSize)), NO_INDEX);
			}
			else
			{
				luaL_argcheck(L, 0, 2, "Can't get this property type.");
			}
			// UMap
			// PointerProperty

		}

		void SetProperty(lua_State * L, UProperty * pProperty, char * pData, int Index)
		{
			if ((Index == NO_INDEX) && (pProperty->ArrayDim > 1))
			{
				luaL_argcheck(L, 0, 2, "Can't set multiple array elements.");
				return;
			}

			if ((Index != NO_INDEX) && (pProperty->ArrayDim == 1) &&
				!pProperty->IsA(UArrayProperty::StaticClass()))
			{
				luaL_argcheck(L, 0, 2, "Property cannot be indexed.");
				return;
			}

			if (Index == NO_INDEX)
				Index = 0;

			if ((Index < 0) || ((unsigned long)Index >= pProperty->ArrayDim))
			{
				luaL_argcheck(L, 0, 2, "Index out of range.");
				return;
			}

			if (pProperty->IsA(UByteProperty::StaticClass()))
			{
				unsigned char value = (unsigned char)luaL_checkinteger(L, 3);

				*(unsigned char*)(pData + pProperty->Offset +
					(pProperty->ElementSize * Index)) = value;
			}
			else if (pProperty->IsA(UIntProperty::StaticClass()))
			{
				int value = luaL_checkinteger(L, 3);

				*(int *)(pData + pProperty->Offset +
					(pProperty->ElementSize * Index)) = value;
			}
			else if (pProperty->IsA(UFloatProperty::StaticClass()))
			{
				float value = (float)luaL_checknumber(L, 3);

				*(float *)(pData + pProperty->Offset +
					(pProperty->ElementSize * Index)) = value;
			}
			// BoolProperty
			else if (pProperty->IsA(UStrProperty::StaticClass()))
			{
				FString* value = (FString*)(pData + pProperty->Offset +
					(pProperty->ElementSize * Index));

				if (value->Data)
					value->Clear();

				if (!lua_isnil(L, 3))
				{
					const char* arg = luaL_checkstring(L, 3);
					const size_t argSize = strlen(arg)+1;
					wchar_t* wc = new wchar_t[argSize];
					mbstowcs(wc, arg, argSize);
					(*value) = wc; // ICK! Probably mem leaking here
				}
			}
			else if(pProperty->IsA(UNameProperty::StaticClass()))
			{
				*(FName *)(pData + pProperty->Offset +
					(pProperty->ElementSize * Index)) = FName((char*)luaL_checkstring(L, 3));
			}
			// DelegateProperty
			else if(pProperty->IsA(UObjectProperty::StaticClass()) ||
				pProperty->IsA(UClassProperty::StaticClass()))
			{
				UObjectData* pValue = (UObjectData*)luaL_checkudata(L, 3, EngineUObject);
				*(UClass**)(pData + pProperty->Offset +
					(pProperty->ElementSize * Index)) = (UClass *)pValue->pData;
			}
			// InterfaceProperty (Probably same as Class/Object?)
			else if(pProperty->IsA(UStructProperty::StaticClass()))
			{
				UObjectData* pValue = (UObjectData *)luaL_checkudata(L, 3, EngineUObject);
				memcpy(pData + pProperty->Offset + 
					(pProperty->ElementSize * Index), pValue->pData, 
					pProperty->ElementSize);
			}
			else if(pProperty->IsA(UArrayProperty::StaticClass()))
			{
				TArray<char>* pArray = (TArray<char>*)(pData + pProperty->Offset); 
				if ((unsigned long)Index >= pArray->Count)
				{
					luaL_argcheck(L, 0, 2, "Index out of range.");
					return;
				}

				pProperty = ((UArrayProperty*)pProperty)->Inner;
				SetProperty(L, pProperty, (char*)((unsigned long)pArray->Data + 
					(Index * pProperty->ElementSize)), NO_INDEX);
			}
			else
			{
				luaL_argcheck(L, 0, 2, "Can't get this property type.");
			}
		}

		int UObjectIndex(lua_State* L) 
		{
			UObjectData* pObjectData = (UObjectData*)luaL_checkudata(L, 1, EngineUObject);
			const char* pPropertyName = lua_tostring(L, 2);

			//UProperty* pProperty = FindProperty(pObjectData->pClass, pPropertyName);
			UProperty* pProperty = NULL;

			GetProperty(L, pObjectData->pObject, pProperty, pObjectData->pData, NO_INDEX);

			return 1;
		}

		int UObjectNewIndex(lua_State * L) 
		{
			UObjectData* pObjectData = (UObjectData*)luaL_checkudata(L, 1, EngineUObject);
			const char* pPropertyName = lua_tostring(L, 2);

			//UProperty* pProperty = FindProperty(pObjectData->pClass, pPropertyName);
			UProperty* pProperty = NULL;

			SetProperty(L, pProperty, pObjectData->pData, NO_INDEX);

			return 0;
		}

		void Register(lua_State* L)
		{
			luaL_newmetatable(L, EngineUObject);
			lua_pushstring(L, "__index");
			lua_pushcfunction(L, UObjectIndex);
			lua_settable(L, -3);
			lua_pushstring(L, "__newindex");
			lua_pushcfunction(L, UObjectNewIndex);
			lua_settable(L, -3);
			//lua_pushstring(L, "__len");
			//lua_pushcfunction(L, UObjectLen);
			//lua_settable(L, -3);
			lua_pop(L, 1);
		}
	}
	*/