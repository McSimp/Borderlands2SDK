#include "LuaInterface/CLuaUObject.h"
#include "Logging/Logging.h"
#include "BL2SDK/Util.h"

using LuaManager::g_Lua;

const char* CLuaUObject::MetaName = "UObject";
const int CLuaUObject::MetaID = 100;
CLuaInterface* CLuaUObject::m_Lua;

void CLuaUObject::Register(CLuaInterface* pLua)
{
	m_Lua = pLua;

	CLuaObject* metaT = m_Lua->GetMetaTable(MetaName);
		metaT->SetMember("__index", CLuaUObject::Index);
		metaT->SetMember("__tostring", CLuaUObject::ToString);
		metaT->SetMember("__gc", CLuaUObject::GC);
	metaT->UnReference();
}

int CLuaUObject::Index(lua_State* L)
{
	// Currently I'm designing everything such that there is only ever 1 Lua state. This could change.
	m_Lua->CheckType(1, MetaID);
	m_Lua->CheckType(2, Lua::TYPE_STRING);

	CLuaUObject* obj = (CLuaUObject*)m_Lua->GetUserData(1);

	const char* propName = m_Lua->GetString(2);

	UProperty* pProperty = obj->FindProperty(propName);
	obj->PushProperty(pProperty);

	return 1;
}

int CLuaUObject::ToString(lua_State* L)
{
	m_Lua->CheckType(1, MetaID);

	CLuaUObject* obj = (CLuaUObject*)m_Lua->GetUserData(1);

	m_Lua->PushVA("%s: %s", MetaName, obj->m_pObject->GetFullName());

	return 1;
}

int CLuaUObject::GC(lua_State* L)
{
	m_Lua->CheckType(1, MetaID);

	CLuaUObject* obj = (CLuaUObject*)m_Lua->GetUserData(1);

	Logging::Log("GC called for UObject %s\n", obj->m_pObject->GetFullName());

	delete obj;

	return 0;
}

CLuaUObject::CLuaUObject(UObject* pObject)
{
	this->m_pObject = pObject;
}

UProperty* CLuaUObject::FindProperty(const char* propertyName)
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

void UProperty::PushToLua(void* data)
{
	if(this->IsA(UByteProperty::StaticClass()))
	{
		int value = *(unsigned char*)data;
		g_Lua->Push(value);
	}
	else if(this->IsA(UIntProperty::StaticClass()))
	{
		int value = *(int*)data;
		g_Lua->Push(value);
	}
	else if(this->IsA(UFloatProperty::StaticClass()))
	{
		float value = *(float*)data;
		g_Lua->Push(value);
	}
	else if(this->IsA(UBoolProperty::StaticClass()))
	{
		Logging::Log("[Lua] Hey! Pushing a bool property needs testing!");
		Logging::Log("Bool Prop bitmask = 0x%X\n", ((UBoolProperty*)this)->BitMask);
		unsigned long value = *(int*)data; // Raw data with up to 32 booleans in it
		value &= ((UBoolProperty*)this)->BitMask; // Check if the bit specified in the property is set
		g_Lua->Push(value != 0);
	}
	else if(this->IsA(UStrProperty::StaticClass()))
	{
		FString* value = (FString*)data;
		if(value->Data)
		{
			std::string str = Util::Narrow(value->Data);
			g_Lua->Push(str.c_str());
		}
		else
		{
			g_Lua->PushNil();
		}
	}
	else if(this->IsA(UNameProperty::StaticClass()))
	{
		FName value = *(FName*)data;
		g_Lua->Push(value.GetName());
	}
	else if(this->IsA(UObjectProperty::StaticClass()) 
		|| this->IsA(UClassProperty::StaticClass()) 
		|| this->IsA(UInterfaceProperty::StaticClass()))
	{
		UObject* value = *(UObject**)data;

		if(value)
		{
			CLuaUObject* luaObj = new CLuaUObject(value);

			CLuaObject* metaT = g_Lua->GetMetaTable(CLuaUObject::MetaName);
				g_Lua->PushUserData(metaT, luaObj, CLuaUObject::MetaID);
			metaT->UnReference();
		}
		else
		{
			g_Lua->PushNil();
		}
	}
	else
	{
		g_Lua->LuaError("Cannot push this property type");
	}
	// UDelegateProperty
	// UStructProperty
	// UMapProperty (not present in BL2)
}

void UProperty::PushToLua(UObject* object, int index)
{
	void* data = (void*)((unsigned char*)object + this->Offset + (this->ElementSize * index));
	Logging::Log("UObject = 0x%X, Offset = 0x%X, ElementSize = 0x%X, Index = %d, Data = 0x%X\n", object, this->Offset, this->ElementSize, index, data);
	this->PushToLua(data);
}

void CLuaUObject::PushProperty(UProperty* pProperty)
{
	// Property types:
	// UByteProperty, UIntProperty, UFloatProperty, UBoolProperty, UStrProperty, UNameProperty
	// UDelegateProperty, UObjectProperty, UClassProperty, UInterfaceProperty, UStructProperty
	// UArrayProperty, UMapProperty
	// and UFunction

	// UArrayProperty means that it's a TArray< innerType > propertyName, 
	// an ArrayDim > 1 means that it's type propertyName[ArrayDim], and it'll just be the normal type (like UByteProperty)

	if(pProperty == NULL)
	{
		m_Lua->PushNil();
		return;
	}

	//m_Lua->Push(pProperty->Name.GetName());

	if(pProperty->IsA(UFunction::StaticClass()))
	{
		// NOT IMPLEMENT LOL.
		g_Lua->LuaError("That's a function you silly duffer!");
	}
	else
	{
		pProperty->PushToLua(this->m_pObject);
	}
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
			
			// DelegateProperty
			
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