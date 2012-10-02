#include "Detours/DetourManager.h"
#include "BL2SDK/BL2SDK.h"
#include "Logging/Logging.h"

#pragma comment (lib, "detours.lib")

namespace DetourManager
{
	tProcessEvent pProcessEvent;

	//typedef HCURSOR (APIENTRY* tSetCursor) (HCURSOR);
	//tSetCursor pSetCursor = SetCursor;

	//typedef HRESULT (APIENTRY* tEndScene) (IDirect3DDevice9*);
	//tEndScene pEndScene = NULL;

	bool AttachProcessEvent()
	{
		pProcessEvent = reinterpret_cast<tProcessEvent>(BL2SDK::ProcessEventAddr());
		DetourTransactionBegin();
		DetourUpdateThread(GetCurrentThread());
		DetourAttach(&(PVOID&)pProcessEvent, BL2SDK::hkRawProcessEvent);
		return (DetourTransactionCommit() == NO_ERROR);
	}
}