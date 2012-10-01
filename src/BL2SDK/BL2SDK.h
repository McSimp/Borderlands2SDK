#ifndef BL2SDK_H
#define BL2SDK_H

#include "GameSDK/GameSDK.h"

namespace BL2SDK
{
	void hkRawProcessEvent();
	void __stdcall hkProcessEvent(UObject* pCaller, UFunction* pFunction, void* pParms, void* pResult);
	void LogAllEvents(bool);
}

#endif