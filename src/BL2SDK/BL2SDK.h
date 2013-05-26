#ifndef BL2SDK_H
#define BL2SDK_H

#include "GameSDK/GameSDK.h"
#include "BL2SDK/Settings.h"

#include <string>

namespace BL2SDK
{
	typedef void (__thiscall *tProcessEvent) (UObject*, UFunction*, void*, void*);
	//typedef int (tUnrealEH) (unsigned int, struct _EXCEPTION_POINTERS*);
	typedef void (__thiscall *tCallFunction) (UObject*, FFrame&, void* const, UFunction*);
	typedef void (__thiscall *tFrameStep) (FFrame*, UObject*, void* const);
	typedef void (__thiscall *tProcessDeferredMessage) (FWindowsViewport*, const FDeferredMessage&);

	extern tProcessEvent pProcessEvent;
	extern tCallFunction pCallFunction;
	extern tFrameStep pFrameStep;
	extern tProcessDeferredMessage pProcessDeferredMessage;

	void LogAllProcessEventCalls(bool enabled);
	void LogAllUnrealScriptCalls(bool enabled);
	bool GetGameVersion(std::wstring& appVersion);
	void InjectedCallNext();
	void Initialize(LauncherStruct* args);
	void Cleanup();

	const std::string Version = "Fucking kawaii";
	const std::wstring VersionW = L"Fucking kawaii";
}

#endif