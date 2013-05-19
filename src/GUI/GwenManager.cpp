#include "GUI/GwenManager.h"
#include "BL2SDK/Logging.h"
#include "Gwen/Gwen.h"
#include "Gwen/Skins/Simple.h"
#include "Gwen/Skins/TexturedBase.h"
#include "Gwen/UnitTest/UnitTest.h"
#include "Gwen/Input/Windows.h"
#include "Gwen/Renderers/DirectX9.h"
#include "BL2SDK/Settings.h"
#include "Commands/ConCommand.h"
#include "BL2SDK/Util.h"

using namespace Gwen;

namespace GwenManager
{
	Renderer::DirectX9* pRenderer = NULL;
	Skin::TexturedBase* pSkin = NULL;
	Controls::Canvas* pCanvas = NULL;

	void InitializeRenderer(IDirect3DDevice9* pD3DDev)
	{
		if(pRenderer) delete pRenderer;
		if(pSkin) delete pSkin;

		Logging::Log("[Gwen] Initializing Renderer\n");
		pRenderer = new Renderer::DirectX9(pD3DDev);

		pSkin = new Skin::TexturedBase(pRenderer);
		pSkin->Init(Settings::GetBinFile(L"DefaultSkin.png"));
	}

	void CreateCanvas(int x, int y)
	{
		if(pCanvas) delete pCanvas;

		Logging::LogF("[Gwen] Creating canvas (%dx%d)\n", x, y);
		pCanvas = new Controls::Canvas(pSkin);
		pCanvas->SetSize(x, y);

		//pCanvas->SetDrawBackground(true);
		//pCanvas->SetBackgroundColor(Gwen::Color(150, 170, 170, 100));
	}

	void OnEndScene()
	{
		if(pCanvas != NULL)
		{
			HWND focusWindow = ::GetForegroundWindow();
			HWND gameWindow = *(HWND*)BL2SDK::pGGameWindow;

			if(focusWindow == gameWindow)
			{
				POINT P;
				::GetCursorPos(&P);
				::ScreenToClient(gameWindow, &P);

				pCanvas->InputMouseMoved(P.x, P.y, 0, 0);
			}

			pCanvas->RenderCanvas();
		}
	}

	enum GwenControls
	{
		GWEN_BUTTON,
		GWEN_WINDOW
	};

	extern "C" __declspec(dllexport) Controls::Base* LUAFUNC_CreateNewControl(GwenControls controlNum)
	{
		Controls::Base* parent = pCanvas;
		Controls::Base* control = NULL;

		if(controlNum == GWEN_BUTTON)
		{
			Controls::Button* btn = new Controls::Button(parent);
			//btn->SetText("YOU ARE FAGET");
			control = btn;
		}
		else if(controlNum == GWEN_WINDOW)
		{
			control = new Controls::WindowControl(parent);
		}
		
		return control;
	}

	extern "C" __declspec(dllexport) TextObject* LUAFUNC_NewTextObject(const char* str)
	{
		return new TextObject(str);
	}

	extern "C" __declspec(dllexport) const char* LUAFUNC_GetTextObjectString(TextObject& obj)
	{
		return obj.c_str();
	}

	extern "C" __declspec(dllexport) void LUAFUNC_SetWindowTitle(Controls::WindowControl* window, const char* str)
	{
		window->SetTitle(str);
	}

	CON_COMMAND(CleanupCanvas)
	{
		pCanvas->RemoveAllChildren();
	}
}
