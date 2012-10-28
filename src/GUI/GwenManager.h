#ifndef GWENMANAGER_H
#define GWENMANAGER_H

#include <d3d9.h>

namespace GwenManager
{
	bool Initialize(IDirect3DDevice9* pD3DDev);
	void OnEndScene();
}

#endif