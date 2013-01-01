#ifndef LUAUOBJECT_H
#define LUAUOBJECT_H

#include "LuaInterface/LuaManager.h"
#include "BL2SDK/BL2SDK.h"

namespace LuaUObject
{
	const char* const MetaName = "UObject";
	const int MetaID = 100;

	void Register();
	void PushInstance(UObject* obj);
}

#endif