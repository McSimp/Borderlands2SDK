#include "BL2SDK/BL2SDK.h"
#include "Detours/DetourManager.h"
#include "Logging/Logging.h"
#include "BL2SDK/CSigScan.h"

namespace BL2SDK
{
	bool										bInjectedCallNext = false;
	bool										bLogAllEvents = false;
	std::list<tFuncNameHookPair>				FuncsToFind;
	std::map<UFunction*, tProcessEventHook*>	HookedFunctions;

	unsigned long								addrGObjects;
	unsigned long								addrGNames;
	unsigned long								addrProcEvent;

	void __stdcall hkProcessEvent(UObject* pCaller, UFunction* pFunction, void* pParms, void* pResult)
	{
		// Save the registers
		_asm pushad;

		if(bInjectedCallNext)
		{
			bInjectedCallNext = false;
			_asm popad;
			DetourManager::pProcessEvent(pCaller, pFunction, pParms, pResult);
			return;
		}

		// There might be a better way to do this, I don't know C++ very well
		std::string CallerName = pCaller->GetFullName();
		std::string FunctionName = pFunction->GetFullName();

		if(bLogAllEvents)
		{
			Logging::Log("===== ProcessEvent called =====\n");
			Logging::Log("pCaller Name = %s\n", CallerName.c_str());
			Logging::Log("pFunction Name = %s\n", FunctionName.c_str());
		}

		// Resolve the functions names that need to be hooked into function pointers for later
		std::list<tFuncNameHookPair>::iterator iFuncsToFind;
		//for(iFuncsToFind = FuncsToFind.begin(); iFuncsToFind != FuncsToFind.end(); iFuncsToFind++)
		iFuncsToFind = FuncsToFind.begin();
		while(iFuncsToFind != FuncsToFind.end())
		{
			tFuncNameHookPair p = *iFuncsToFind;
			if(!p.first.compare(FunctionName))
			{
				Logging::Log("[Engine Hooks] Hook created for \"%s\"\n", FunctionName.c_str());
				HookedFunctions.insert(std::make_pair(pFunction, p.second));
				iFuncsToFind = FuncsToFind.erase(iFuncsToFind);
			}
			else
			{
				iFuncsToFind++;
			}
		}

		// Call the function hook (if any) for this pFunction
		std::map<UFunction*, tProcessEventHook*>::iterator iHookedFunctions = HookedFunctions.find(pFunction);
		if(iHookedFunctions != HookedFunctions.end())
		{
			if(!iHookedFunctions->second(pCaller, pFunction, pParms, pResult))
			{
				// If the hook returns false, then don't call ProcessEvent in the engine
				_asm popad;
				return;
			}
		}

		_asm popad;
		DetourManager::pProcessEvent(pCaller, pFunction, pParms, pResult);
		return;
	}

	void __declspec(naked) hkRawProcessEvent()
	{
		__asm
		{
			push ebp
			mov ebp, esp
			push [ebp+16]
			push [ebp+12]
			push [ebp+8]
			push ecx
			call hkProcessEvent
			pop ebp
			retn 12
		}
	}

	void InjectedCallNext()
	{
		bInjectedCallNext = true;
	}

	void LogAllEvents(bool enabled)
	{
		bLogAllEvents = enabled;
	}

	void RegisterHook(const std::string& funcName, tProcessEventHook* funcHook)
	{
		tFuncNameHookPair pair = std::make_pair(funcName, funcHook);
		FuncsToFind.push_back(pair);
	}

	unsigned long GObjects()
	{
		return addrGObjects;
	}

	unsigned long GNames()
	{
		return addrGNames;
	}

	unsigned long ProcessEventAddr()
	{
		return addrProcEvent;
	}

	bool Initialize()
	{
		// Setup Sigscan
		CSigScan::module_handle = GetModuleHandle(L"Borderlands2.exe");
		if(CSigScan::module_handle == NULL || !CSigScan::GetModuleMemInfo())
		{
			Logging::Log("[ERROR] Code = SDKMEMBASEERR. Failed to find base of Borderlands2.exe\n");
			return false;
		}

		unsigned long base = (unsigned long)CSigScan::module_handle;
		Logging::Log("[INTERNAL] Game base pointer = 0x%X\n", base);

		// Scan for GObjects
		CSigScan GObjectsSig;
		int GObjResult = GObjectsSig.Init((unsigned char*)GObjects_Pattern, GObjects_Mask, GObjects_SigLen);
		if(!GObjectsSig.is_set)
		{
			Logging::Log("[ERROR] Code = GOBJSIGFAIL (%i). Failed to sigscan for GObjects.\n", GObjResult);	
			return false;
		}
		addrGObjects = *((unsigned long*)((unsigned long)GObjectsSig.sig_addr + MOV_OP_OFFSET));
		Logging::Log("[INTERNAL] GObjects = 0x%X (Offset = 0x%X)\n", addrGObjects, (addrGObjects - base));

		// Scan for GNames
		CSigScan GNamesSig;
		GNamesSig.Init((unsigned char*)GNames_Pattern, GNames_Mask, GNames_SigLen);
		if(!GNamesSig.is_set)
		{
			Logging::Log("[ERROR] Code = GNAMESSIGFAIL. Failed to sigscan for GNames.\n");	
			return false;
		}
		addrGNames = *((unsigned long*)((unsigned long)GNamesSig.sig_addr + MOV_OP_OFFSET));
		Logging::Log("[INTERNAL] GNames = 0x%X (Offset = 0x%X)\n", addrGNames, (addrGNames - base));

		// Scan for UObject::ProcessEvent
		CSigScan ProcEventSig;
		ProcEventSig.Init((unsigned char*)ProcessEvent_Pattern, ProcessEvent_Mask, ProcessEvent_SigLen);
		if(!ProcEventSig.is_set)
		{
			Logging::Log("[ERROR] Code = PROCEVENTSIGFAIL. Failed to sigscan for UObject::ProcessEvent().\n");	
			return false;
		}
		addrProcEvent = (unsigned long)ProcEventSig.sig_addr;
		Logging::Log("[INTERNAL] UObject::ProcessEvent = 0x%X (Offset = 0x%X)\n", addrProcEvent, (addrProcEvent - base));

		// Detour UObject::ProcessEvent()
		if(!DetourManager::AttachProcessEvent())
		{
			Logging::Log("[ERROR] Code = PROCEVENTDETOURFAIL. Failed to attach to UObject::ProcessEvent().\n");
			return false;
		}

		return true;
	}
}