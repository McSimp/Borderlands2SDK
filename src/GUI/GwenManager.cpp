#include "GUI/GwenManager.h"
#include "Logging/Logging.h"
#include "Gwen/Gwen.h"
#include "Gwen/Skins/Simple.h"
#include "Gwen/Skins/TexturedBase.h"
#include "Gwen/UnitTest/UnitTest.h"
#include "Gwen/Input/Windows.h"
#include "Gwen/Renderers/DirectX9.h"

namespace GwenManager
{
	Gwen::Renderer::DirectX9* pRenderer = NULL;
	Gwen::Skin::TexturedBase* pSkin = NULL;
	Gwen::Controls::Canvas* pCanvas = NULL;

	bool Initialize(IDirect3DDevice9* pD3DDev)
	{
		Logging::Log("[Gwen] Initializing...\n");
		pRenderer = new Gwen::Renderer::DirectX9(pD3DDev);

		pSkin = new Gwen::Skin::TexturedBase(pRenderer);
		pSkin->Init("DefaultSkin.png"); // TODO: Load from GWEN location in registry

		pCanvas = new Gwen::Controls::Canvas(pSkin);
		pCanvas->SetSize(1024, 768);
		pCanvas->SetDrawBackground(true);
		pCanvas->SetBackgroundColor(Gwen::Color(150, 170, 170, 255));

		Logging::Log("[Gwen] Ready\n");
		return true;
	}

	void OnEndScene()
	{
		if(pCanvas != NULL)
		{
			pCanvas->RenderCanvas();
		}
	}
}