#ifndef GWENMANAGER_H
#define GWENMANAGER_H

#include <string>
#include <d3d9.h>

namespace GwenManager
{
	void InitializeRenderer(IDirect3DDevice9* pD3DDev);
	void UpdateCanvas(int x, int y);
	void OnEndScene();
	void DisplayMessageBox(const std::string& title, const std::string& message, bool exitOnClose = false);
}

#endif

