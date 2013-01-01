#ifndef LUAPROPERTYARRAY_H
#define LUAPROPERTYARRAY_H

#include "LuaInterface/LuaManager.h"
#include "BL2SDK/BL2SDK.h"

namespace LuaPropertyArray
{
	const char* const MetaName = "PropertyArray";
	const int MetaID = 102;

	void Register();
	void PushInstance(UProperty* property, UObject* object);
}

#endif