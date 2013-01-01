#ifndef LUAUOBJECTTABLE_H
#define LUAUOBJECTTABLE_H

#include "LuaInterface/LuaManager.h"
#include "BL2SDK/BL2SDK.h"

namespace LuaUObjectTable
{
	const char* const MetaName = "UObjectTable";
	const int MetaID = 101;

	void Register();
}

#endif