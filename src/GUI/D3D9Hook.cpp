#include "GUI/D3D9Hook.h"
#include "GUI/GwenManager.h"
#include "Logging/Logging.h"
#include "BL2SDK/Exceptions.h"
#include "BL2SDK/Util.h"
#include <d3d9.h>
#include <d3dx9.h>

#define CREATEDEVICE_IDX 16
#define ENDSCENE_IDX 42

namespace D3D9Hook
{
	typedef HRESULT (WINAPI* tCreateDevice)(IDirect3D9*, UINT, D3DDEVTYPE, HWND, DWORD, D3DPRESENT_PARAMETERS*, IDirect3DDevice9**);
	typedef HRESULT (WINAPI* tEndScene)(IDirect3DDevice9*);

	tCreateDevice pCreateDevice = NULL;
	tEndScene pEndScene = NULL;
	PDWORD D3DVTable = NULL;
	PDWORD D3DDVTable = NULL;
	IDirect3DDevice9* pD3DDev = NULL;

	HRESULT WINAPI EndScene_Detour(IDirect3DDevice9* pD3DDev)
	{
		GwenManager::OnEndScene();
		return pEndScene(pD3DDev);
	}

	HRESULT WINAPI hkCreateDevice(IDirect3D9* pD3D, UINT Adapter, D3DDEVTYPE DeviceType, HWND hFocusWindow, 
								   DWORD BehaviorFlags, D3DPRESENT_PARAMETERS* pPresentationParameters, 
								   IDirect3DDevice9** ppReturnedDeviceInterface)
	{
		HRESULT result = pCreateDevice(pD3D, Adapter, DeviceType, hFocusWindow, BehaviorFlags, pPresentationParameters, ppReturnedDeviceInterface);

		if(result != D3D_OK)
		{
			Logging::Log("[DirectX Hooking] Call to CreateDevice failed (Return = 0x%X)\n", result);
			return result;
		}

		DWORD dwProtect;

		// Restore the original CreateDevice function to the D3D VTable
		if(VirtualProtect(&D3DVTable[CREATEDEVICE_IDX], sizeof(DWORD), PAGE_READWRITE, &dwProtect) == 0)
		{
			Logging::Log("[DirectX Hooking] VirtualProtect failed for removing CreateDevice hook\n");
			return D3DERR_INVALIDCALL;
		}

		*(PDWORD)&D3DVTable[CREATEDEVICE_IDX] = *(PDWORD)&pCreateDevice;
		pCreateDevice = NULL;

		if(VirtualProtect(&D3DVTable[CREATEDEVICE_IDX], sizeof(DWORD), dwProtect, &dwProtect) == 0)
		{
			Logging::Log("[DirectX Hooking] VirtualProtect failed for removing CreateDevice hook\n");
			return D3DERR_INVALIDCALL;	
		}

		D3DDVTable = (PDWORD)*(PDWORD)*ppReturnedDeviceInterface;
		pD3DDev = *ppReturnedDeviceInterface;

		// TODO: May need to VirtualProtect here
		*(PDWORD)&pEndScene = (DWORD)D3DDVTable[ENDSCENE_IDX];
		*(PDWORD)&D3DDVTable[ENDSCENE_IDX] = (DWORD)EndScene_Detour; // This may need a more aggressive set (ie. check every second and overwrite)
		
		Logging::Log("[DirectX Hooking] EndScene hooked successfully\n");

		GwenManager::Initialize(pD3DDev);

		return result;
	}


	void Initialize()
	{
		IDirect3D9* d3d = Direct3DCreate9(D3D_SDK_VERSION);
		if(d3d == NULL)
		{
			throw FatalSDKException(5000, Util::Format("Failed to call Direct3DCreate9 (Error = %d)", GetLastError()));
		}

		D3DVTable = (PDWORD)*(PDWORD)d3d;
		d3d->Release();

		DWORD dwProtect;

		// Rewrite the pointer to CreateDevice in the VTable to our own function
		if(VirtualProtect(&D3DVTable[CREATEDEVICE_IDX], sizeof(DWORD), PAGE_READWRITE, &dwProtect) == 0)
		{
			throw FatalSDKException(5001, Util::Format("VirtualProtect failed for adding CreateDevice hook (Error = %d)", GetLastError()));
		}

		*(PDWORD)&pCreateDevice = D3DVTable[CREATEDEVICE_IDX];
		*(PDWORD)&D3DVTable[CREATEDEVICE_IDX] = (DWORD)hkCreateDevice;

		if(VirtualProtect(&D3DVTable[CREATEDEVICE_IDX], sizeof(DWORD), dwProtect, &dwProtect) == 0)
		{
			throw FatalSDKException(5002, Util::Format("VirtualProtect failed for adding CreateDevice hook (Error = %d)", GetLastError()));
		}

		Logging::Log("[DirectX Hooking] CreateDevice hooked successfully\n");
	}
}