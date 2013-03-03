#include "GUI/GwenManager.h"
#include "Logging/Logging.h"
#include "Gwen/Gwen.h"
#include "Gwen/Skins/Simple.h"
#include "Gwen/Skins/TexturedBase.h"
#include "Gwen/UnitTest/UnitTest.h"
#include "Gwen/Input/Windows.h"
#include "Gwen/Renderers/DirectX9.h"
#include "BL2SDK/Settings.h"

namespace GwenManager
{
	Gwen::Renderer::DirectX9* pRenderer = NULL;
	Gwen::Skin::TexturedBase* pSkin = NULL;
	Gwen::Controls::Canvas* pCanvas = NULL;

	void InitializeRenderer(IDirect3DDevice9* pD3DDev)
	{
		if(pRenderer) delete pRenderer;
		if(pSkin) delete pSkin;

		Logging::Log("[Gwen] Initializing Renderer\n");
		pRenderer = new Gwen::Renderer::DirectX9(pD3DDev);

		pSkin = new Gwen::Skin::TexturedBase(pRenderer);
		pSkin->Init(Settings::GetBinFile(L"DefaultSkin.png"));
	}

	void CreateCanvas(int x, int y)
	{
		if(pCanvas) delete pCanvas;

		Logging::LogF("[Gwen] Creating canvas (%dx%d)\n", x, y);
		pCanvas = new Gwen::Controls::Canvas(pSkin);
		pCanvas->SetSize(x, y);

		//pCanvas->SetDrawBackground(true);
		//pCanvas->SetBackgroundColor(Gwen::Color(150, 170, 170, 100));
	}

	void OnEndScene()
	{
		if(pCanvas != NULL)
		{
			pCanvas->RenderCanvas();
		}
	}
}