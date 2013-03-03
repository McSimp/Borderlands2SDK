#ifndef GWENMANAGER_H
#define GWENMANAGER_H

#include <d3d9.h>

namespace GwenManager
{
	void InitializeRenderer(IDirect3DDevice9* pD3DDev);
	void CreateCanvas(int x, int y);
	void OnEndScene();
}

#endif