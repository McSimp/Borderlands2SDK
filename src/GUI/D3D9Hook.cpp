#include "GUI/D3D9Hook.h"
#include "GUI/GwenManager.h"
#include "BL2SDK/Logging.h"
#include "BL2SDK/Exceptions.h"
#include "BL2SDK/Util.h"
#include <d3d9.h>
#include <d3dx9.h>

namespace D3D9Hook
{
	const int CREATEDEVICE_IDX = 16;
	const int ENDSCENE_IDX = 42; 
	const int BEGINSTATEBLOCK_IDX = 60;
	const int ENDSTATEBLOCK_IDX = 61;

	typedef HRESULT (WINAPI* tCreateDevice)(IDirect3D9*, UINT, D3DDEVTYPE, HWND, DWORD, D3DPRESENT_PARAMETERS*, IDirect3DDevice9**);
	typedef HRESULT (WINAPI* tEndScene)(IDirect3DDevice9*);
	typedef HRESULT (WINAPI* tBeginStateBlock)(IDirect3DDevice9*);
	typedef HRESULT (WINAPI* tEndStateBlock)(IDirect3DDevice9*, IDirect3DStateBlock9**); 

	tCreateDevice pCreateDevice = NULL;
	tEndScene pEndScene = NULL;
	tBeginStateBlock pBeginStateBlock = NULL;
	tEndStateBlock pEndStateBlock = NULL;
	PDWORD D3DVTable = NULL;
	PDWORD D3DDVTable = NULL;
	IDirect3DDevice9* pD3DDev = NULL;

	HRESULT WINAPI EndScene_Detour(IDirect3DDevice9* pD3DDev);
	HRESULT WINAPI BeginStateBlock_Detour(IDirect3DDevice9* pD3DDev);
	HRESULT WINAPI EndStateBlock_Detour(IDirect3DDevice9* pD3DDDev, IDirect3DStateBlock9** ppSB);

	HRESULT WINAPI EndScene_Detour(IDirect3DDevice9* pD3DDev)
	{
		GwenManager::OnEndScene();
		return pEndScene(pD3DDev);
	}

	HRESULT WINAPI BeginStateBlock_Detour(IDirect3DDevice9* pD3DDev)
	{
		HRESULT result = pBeginStateBlock(pD3DDev);
		D3DDVTable[ENDSTATEBLOCK_IDX] = (DWORD)EndStateBlock_Detour; // Restore EndStateBlock hook
		return result;
	}

	HRESULT WINAPI EndStateBlock_Detour(IDirect3DDevice9* pD3DDDev, IDirect3DStateBlock9** ppSB)
	{
		HRESULT result = pEndStateBlock(pD3DDDev, ppSB);

		D3DDVTable[ENDSCENE_IDX] = (DWORD)EndScene_Detour;
		D3DDVTable[BEGINSTATEBLOCK_IDX] = (DWORD)BeginStateBlock_Detour;

		return result;
	}

	HRESULT WINAPI hkCreateDevice(IDirect3D9* pD3D, UINT Adapter, D3DDEVTYPE DeviceType, HWND hFocusWindow, 
								   DWORD BehaviorFlags, D3DPRESENT_PARAMETERS* pPresentationParameters, 
								   IDirect3DDevice9** ppReturnedDeviceInterface)
	{
		wchar_t windowName[128];
		GetWindowText(hFocusWindow, windowName, 128);

		Logging::LogF("[DirectX Hooking] CreateDevice called (Thread = %d, Window = %ls)\n", GetCurrentThreadId(), windowName);
		Logging::LogF("[DirectX Hooking] 2: pCreateDevice = 0x%p, hkCreateDevice = 0x%p, D3DVTable = 0x%p\n", pCreateDevice, (DWORD)hkCreateDevice, D3DVTable);

		HRESULT result = pCreateDevice(pD3D, Adapter, DeviceType, hFocusWindow, BehaviorFlags, pPresentationParameters, ppReturnedDeviceInterface);

		Logging::LogF("[DirectX Hooking] pCreateDevice call completed\n");

		if(result != D3D_OK)
		{
			Logging::LogF("[DirectX Hooking] Call to CreateDevice failed (Return = 0x%X)\n", result);
			return result;
		}

		DWORD dwProtect;

		// Restore the original CreateDevice function to the D3D VTable
		if(VirtualProtect(&D3DVTable[CREATEDEVICE_IDX], sizeof(DWORD), PAGE_READWRITE, &dwProtect) == 0)
		{
			Logging::Log("[DirectX Hooking] VirtualProtect failed for removing CreateDevice hook\n");
			return D3DERR_INVALIDCALL;
		}

		D3DVTable[CREATEDEVICE_IDX] = (DWORD)pCreateDevice;
		pCreateDevice = NULL;

		if(VirtualProtect(&D3DVTable[CREATEDEVICE_IDX], sizeof(DWORD), dwProtect, &dwProtect) == 0)
		{
			Logging::Log("[DirectX Hooking] VirtualProtect failed for removing CreateDevice hook\n");
			return D3DERR_INVALIDCALL;	
		}

		D3DDVTable = (PDWORD)*(PDWORD)*ppReturnedDeviceInterface;
		pD3DDev = *ppReturnedDeviceInterface;

		// TODO: May need to VirtualProtect here
		pEndScene = (tEndScene)D3DDVTable[ENDSCENE_IDX];
		D3DDVTable[ENDSCENE_IDX] = (DWORD)EndScene_Detour; // This may need a more aggressive set (ie. check every second and overwrite)
		
		pBeginStateBlock = (tBeginStateBlock)D3DDVTable[BEGINSTATEBLOCK_IDX];
		D3DDVTable[BEGINSTATEBLOCK_IDX] = (DWORD)BeginStateBlock_Detour;

		pEndStateBlock = (tEndStateBlock)D3DDVTable[ENDSTATEBLOCK_IDX];
		D3DDVTable[ENDSTATEBLOCK_IDX] = (DWORD)EndStateBlock_Detour;

		Logging::Log("[DirectX Hooking] EndScene hooked successfully\n");

		GwenManager::InitializeRenderer(pD3DDev);

		return result;
	}


	void Initialize()
	{
		IDirect3D9* d3d = Direct3DCreate9(D3D_SDK_VERSION);
		if(d3d == NULL)
		{
			throw FatalSDKException(5000, Util::Format("Failed to call Direct3DCreate9 (Error = %d)", GetLastError()));
		}

		D3DVTable = *(PDWORD*)d3d;
		d3d->Release();

		DWORD dwProtect;

		// Rewrite the pointer to CreateDevice in the VTable to our own function
		if(VirtualProtect(&D3DVTable[CREATEDEVICE_IDX], sizeof(DWORD), PAGE_READWRITE, &dwProtect) == 0)
		{
			throw FatalSDKException(5001, Util::Format("VirtualProtect failed for adding CreateDevice hook (Error = %d)", GetLastError()));
		}

		pCreateDevice = (tCreateDevice)(D3DVTable[CREATEDEVICE_IDX]);
		D3DVTable[CREATEDEVICE_IDX] = (DWORD)hkCreateDevice;

		Logging::LogF("[DirectX Hooking] 1: pCreateDevice = 0x%p, hkCreateDevice = 0x%p, D3DVTable = 0x%p\n", pCreateDevice, (DWORD)hkCreateDevice, D3DVTable);

		if(VirtualProtect(&D3DVTable[CREATEDEVICE_IDX], sizeof(DWORD), dwProtect, &dwProtect) == 0)
		{
			throw FatalSDKException(5002, Util::Format("VirtualProtect failed for adding CreateDevice hook (Error = %d)", GetLastError()));
		}

		Logging::Log("[DirectX Hooking] CreateDevice hooked successfully\n");
	}
}