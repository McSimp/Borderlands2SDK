#include "LuaInterface/LuaUObject.h"
#include "LuaInterface/LuaPropertyArray.h"
#include "LuaInterface/LuaTArray.h"
#include "Logging/Logging.h"
#include "BL2SDK/Util.h"

using LuaManager::g_Lua;

namespace LuaUObject
{
	int index(lua_State* L)
	{
		// Currently I'm designing everything such that there is only ever 1 Lua state. This could change.
		g_Lua->CheckType(1, MetaID);
		g_Lua->CheckType(2, Lua::TYPE_STRING);

		UObject* obj = (UObject*)g_Lua->GetUserData(1);

		const char* propName = g_Lua->GetString(2);

		UProperty* pProperty = obj->FindProperty(propName);
		obj->PushProperty(pProperty);

		return 1;
	}

	int tostring(lua_State* L)
	{
		g_Lua->CheckType(1, MetaID);

		UObject* obj = (UObject*)g_Lua->GetUserData(1);

		g_Lua->PushVA("%s: %s", MetaName, obj->GetFullName());

		return 1;
	}

	void Register()
	{
		CLuaObject* metaT = g_Lua->GetMetaTable(MetaName);
			metaT->SetMember("__index", index);
			metaT->SetMember("__tostring", tostring);
		metaT->UnReference();
	}

	void PushInstance(UObject* obj)
	{
		CLuaObject* metaT = g_Lua->GetMetaTable(MetaName);
			g_Lua->PushUserData(metaT, obj, MetaID);
		metaT->UnReference();
	}
}

UProperty* UObject::FindProperty(const char* propertyName)
{
	// Basic algorithm:
	// (-> Resolve the property name from Lua to an FName for faster lookup)
	// ^ On second thoughts, this would probably result in more string comparisons and be SLOWER.
	// -> Start with the outermost class. 
	// -> Go through all of the fields in this class to see if it matches the one we want
	// -> If no match found, repeat with the next inherited class.
	// -> If we reach the highest level and we haven't found a match, we failed.

	UProperty* pProperty = NULL;
	UClass* pCurClass = this->Class;

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
		//Logging::Log("[Lua] Hey! Pushing a bool property needs testing!");
		//Logging::Log("Bool Prop bitmask = 0x%X\n", ((UBoolProperty*)this)->BitMask);
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
			Logging::Log("[Lua] Warning: FString property has no data\n");
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
			LuaUObject::PushInstance(value);
		}
		else
		{
			Logging::Log("[Lua] Warning: UObject property is a null pointer\n");
			g_Lua->PushNil();
		}
	}
	else if(this->IsA(UArrayProperty::StaticClass()))
	{
		LuaTArray::PushInstance(((UArrayProperty*)this)->Inner, data);
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
	//Logging::Log("UObject = 0x%X, Offset = 0x%X, ElementSize = 0x%X, Index = %d, Data = 0x%X\n", object, this->Offset, this->ElementSize, index, data);
	this->PushToLua(data);
}

void UProperty::PushAsStaticArray(UObject* object)
{
	LuaPropertyArray::PushInstance(this, object);
}

void UObject::PushProperty(UProperty* pProperty)
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
		Logging::Log("[Lua] Warning: Property does not exist for this UObject\n");
		g_Lua->PushNil();
		return;
	}

	if(pProperty->IsA(UFunction::StaticClass()))
	{
		// NOT IMPLEMENT LOL.
		g_Lua->LuaError("That's a function you silly duffer!");
	}
	else if(pProperty->ArrayDim > 1)
	{
		pProperty->PushAsStaticArray(this);
	}
	else
	{
		pProperty->PushToLua(this);
	}
}
