#ifndef LUATARRAY_H
#define LUATARRAY_H

#include "LuaInterface/LuaManager.h"
#include "BL2SDK/BL2SDK.h"

namespace LuaTArray
{
	const char* const MetaName = "TArray";
	const int MetaID = 103;

	void Register();
	void PushInstance(UProperty* prop, void* data);
}

#endif