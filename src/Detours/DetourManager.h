#ifndef DETOURMANGER_H
#define DETOURMANGER_H

#include "Detours/CSimpleDetour.h"
#include "GameSDK/GameSDK.h"

namespace DetourManager
{
	typedef void (__thiscall *tProcessEvent) (UObject*, UFunction*, void*, void*);
	extern tProcessEvent pProcessEvent;
	//extern CSimpleDetour ProcessEvent_Detour;
	void AttachProcessEvent();
}

#endif