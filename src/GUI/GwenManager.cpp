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
#include "BL2SDK/CSimpleDetour.h"

#define GET_X_LPARAM(lParam)	((int)(short)LOWORD(lParam))
#define GET_Y_LPARAM(lParam)	((int)(short)HIWORD(lParam))

using namespace Gwen;

namespace GwenManager
{
	Renderer::DirectX9* pRenderer = NULL;
	Skin::TexturedBase* pSkin = NULL;
	Controls::Canvas* pCanvas = NULL;

	bool gwenEnabled = false;

	void __stdcall hkProcessDeferredMessage(const FDeferredMessage& deferredMessage)
	{
		FWindowsViewport* thisPtr;
		_asm mov thisPtr, ecx;

		if(deferredMessage.Message == WM_KEYDOWN && deferredMessage.wParam == VK_F3)
		{
			gwenEnabled = !gwenEnabled;
		}

		if(gwenEnabled && pCanvas)
		{
			const WPARAM wParam = deferredMessage.wParam;
			const LPARAM lParam = deferredMessage.lParam;

			switch(deferredMessage.Message)
			{
			case WM_MOUSEMOVE:
				{
					int X = GET_X_LPARAM(lParam);
					int Y = GET_Y_LPARAM(lParam);
					pCanvas->InputMouseMoved(X, Y, 0, 0);
					return;
				}
				break;
			
			case WM_CHAR:
			case WM_SYSCHAR:
				{
					Gwen::UnicodeChar chr = (Gwen::UnicodeChar)wParam;
					pCanvas->InputCharacter(chr);
					return;
				}
				break;
			case WM_KEYDOWN:
			case WM_KEYUP:
				{
					bool bDown = deferredMessage.Message == WM_KEYDOWN;
					int iKey = -1;

					// These aren't sent by WM_CHAR when CTRL is down - but we need
					// them internally for copy and paste etc..
					if(bDown && GetKeyState(VK_CONTROL) & 0x80 && wParam >= 'A' && wParam <= 'Z')
					{
						Gwen::UnicodeChar chr = (Gwen::UnicodeChar) wParam;
						pCanvas->InputCharacter(chr);
						return;
					}

					if(wParam == VK_SHIFT) { iKey = Gwen::Key::Shift; }
					else if(wParam == VK_RETURN) { iKey = Gwen::Key::Return; }
					else if(wParam == VK_BACK) { iKey = Gwen::Key::Backspace; }
					else if(wParam == VK_DELETE) { iKey = Gwen::Key::Delete; }
					else if(wParam == VK_LEFT) { iKey = Gwen::Key::Left; }
					else if(wParam == VK_RIGHT) { iKey = Gwen::Key::Right; }
					else if(wParam == VK_TAB) { iKey = Gwen::Key::Tab; }
					else if(wParam == VK_SPACE) { iKey = Gwen::Key::Space; }
					else if(wParam == VK_HOME) { iKey = Gwen::Key::Home; }
					else if(wParam == VK_END) { iKey = Gwen::Key::End; }
					else if(wParam == VK_CONTROL) { iKey = Gwen::Key::Control; }
					else if(wParam == VK_SPACE) { iKey = Gwen::Key::Space; }
					else if(wParam == VK_UP) { iKey = Gwen::Key::Up; }
					else if(wParam == VK_DOWN) { iKey = Gwen::Key::Down; }

					if(iKey != -1)
					{
						pCanvas->InputKey(iKey, bDown);
						return;
					}
				}
				break;
			case WM_LBUTTONDOWN:
				{
					pCanvas->InputMouseButton(0, true);
					return;
				}
				break;

			case WM_LBUTTONUP:
				{
					pCanvas->InputMouseButton(0, false);
					return;
				}
				break;
			case WM_RBUTTONDOWN:
				{
					pCanvas->InputMouseButton(1, true);
					return;
				}
				break;
			case WM_RBUTTONUP:
				{
					pCanvas->InputMouseButton(1, false);
					return;
				}
			}
		}

		BL2SDK::pProcessDeferredMessage(thisPtr, deferredMessage);
	}

	void InitializeRenderer(IDirect3DDevice9* pD3DDev)
	{
		if(pRenderer) delete pRenderer;
		if(pSkin) delete pSkin;

		Logging::Log("[Gwen] Initializing Renderer\n");
		pRenderer = new Renderer::DirectX9(pD3DDev);

		pSkin = new Skin::TexturedBase(pRenderer);
		pSkin->Init(Settings::GetBinFile(L"DefaultSkin.png"));

		// Detour FWindowsViewport::ProcessDeferredMessage
		SETUP_SIMPLE_DETOUR(detProcessDeferredMessage, BL2SDK::pProcessDeferredMessage, hkProcessDeferredMessage);
		detProcessDeferredMessage.Attach();
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
			pCanvas->RenderCanvas();
		}
	}

	enum GwenControls
	{
		GWEN_BUTTON,
		GWEN_WINDOW
	};

	extern "C" __declspec(dllexport) Controls::Base* LUAFUNC_CreateNewControl(GwenControls controlNum, Controls::Base* parent)
	{
		if(parent == NULL)
		{
			parent = pCanvas;
		}
		Controls::Base* control = NULL;

		if(controlNum == GWEN_BUTTON)
		{
			Controls::Button* btn = new Controls::Button(parent);
			control = btn;
		}
		else if(controlNum == GWEN_WINDOW)
		{
			Controls::WindowControl* wnd = new Controls::WindowControl(parent);
			wnd->SetDeleteOnClose(true);
			control = wnd;
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
