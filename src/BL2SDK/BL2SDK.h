#ifndef BL2SDK_H
#define BL2SDK_H

#include "GameSDK/GameSDK.h"
#include "BL2SDK/Settings.h"
#include "LuaInterface/CLuaInterface.h"

#include <string>

namespace BL2SDK
{
	typedef void (__thiscall *tProcessEvent) (UObject*, UFunction*, void*, void*);
	//typedef int (tUnrealEH) (unsigned int, struct _EXCEPTION_POINTERS*);
	typedef void (__thiscall *tCallFunction) (UObject*, FFrame&, void* const, UFunction*);
	typedef void (__thiscall *tFrameStep) (FFrame*, UObject*, void* const);
	typedef UObject* (*tStaticConstructObject) (UClass* inClass, UObject* outer, FName name, unsigned int flags, UObject* inTemplate, FOutputDevice* error, UObject* root, void* unk);
	typedef UPackage* (*tLoadPackage) (UPackage* outer, const wchar_t* filename, DWORD flags);
	typedef FArchive& (__thiscall *tByteOrderSerialize) (FArchive* Ar, void* V, int Length);

	extern void* pTextureFixLocation;

	extern tProcessEvent pProcessEvent;
	extern tCallFunction pCallFunction;
	extern tFrameStep pFrameStep;
	extern tStaticConstructObject pStaticConstructObject;
	extern tLoadPackage pLoadPackage;
	extern tByteOrderSerialize pByteOrderSerialize;

	extern CLuaInterface* Lua;

	extern int EngineVersion;
	extern int ChangelistNumber;

	void LogAllProcessEventCalls(bool enabled);
	void LogAllUnrealScriptCalls(bool enabled);
	bool GetGameVersion(std::wstring& appVersion);
	void InjectedCallNext();
	void Initialize(LauncherStruct* args);
	void Cleanup();
}

#endif