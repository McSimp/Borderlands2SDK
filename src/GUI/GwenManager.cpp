#include "GUI/GwenManager.h"
#include "BL2SDK/Logging.h"
#include "Gwen/Gwen.h"
#include "Gwen/Skins/Simple.h"
#include "Gwen/Skins/TexturedBase.h"
#include "Gwen/Input/Windows.h"
#include "GUI/DirectX9.h"
#include "BL2SDK/Settings.h"
#include "Commands/ConCommand.h"
#include "BL2SDK/Util.h"
#include "BL2SDK/CSimpleDetour.h"
#include "BL2SDK/GameHooks.h"
#include "LuaInterface/Exports.h"

// Controls
#include "gwen/Controls.h"

#define GET_X_LPARAM(lParam)	((int)(short)LOWORD(lParam))
#define GET_Y_LPARAM(lParam)	((int)(short)HIWORD(lParam))

using namespace Gwen;

namespace GwenManager
{
	Renderer::DirectX9* pRenderer = NULL;
	Skin::TexturedBase* pSkin = NULL;
	Controls::Canvas* pCanvas = NULL;

	typedef void (__thiscall* tGwenBaseDestructor) (Controls::Base*);
	typedef void (*tGwenBaseDestructorHook) (Controls::Base*);

	tGwenBaseDestructorHook destructorHook = NULL;

	bool gwenEnabled = false;

	void ToggleGwenActive()
	{
		gwenEnabled = !gwenEnabled;
		APlayerController* pc = UObject::FindObject<APlayerController>("WillowPlayerController TheWorld.PersistentLevel.WillowPlayerController");
		if(pc != NULL)
		{
			pc->IgnoreButtonInput(gwenEnabled);
			pc->IgnoreLookInput(gwenEnabled);
			pc->IgnoreMoveInput(gwenEnabled);
		}
	}

	void __stdcall hkProcessDeferredMessage(const FDeferredMessage& deferredMessage)
	{
		FWindowsViewport* thisPtr;
		_asm mov thisPtr, ecx;

		if(deferredMessage.Message == WM_KEYDOWN && deferredMessage.wParam == VK_F3)
		{
			ToggleGwenActive();
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
					}

					return;
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
				break;
			case WM_SETCURSOR:
				{
					SetCursor(LoadCursor(NULL, IDC_ARROW));
					return;
				}
				break;
			}
		}

		BL2SDK::pProcessDeferredMessage(thisPtr, deferredMessage);
	}

	void __stdcall hkGwenDestructor()
	{
		Controls::Base* caller;
		_asm mov caller, ecx;

		if(destructorHook != NULL)
		{
			destructorHook(caller);
		}

		((tGwenBaseDestructor)BL2SDK::pGwenDestructor)(caller);
	}

	void __stdcall hkViewportResize(unsigned int newSizeX, unsigned int newSizeY, bool newFullscreen, bool unknown, int posX, int posY)
	{
		FWindowsViewport* caller;
		_asm mov caller, ecx;

		Logging::LogF("[Gwen] Viewport resized: ResX = %d, ResY = %d, Fullscreen = %d, Unk = %d\n", newSizeX, newSizeY, newFullscreen, unknown);

		BL2SDK::pViewportResize(caller, newSizeX, newSizeY, newFullscreen, unknown, posX, posY);
	}

	void InitializeRenderer(IDirect3DDevice9* pD3DDev)
	{
		if(pRenderer) delete pRenderer;
		if(pSkin) delete pSkin;

		Logging::Log("[Gwen] Initializing Renderer\n");
		pRenderer = new Renderer::DirectX9(pD3DDev);

		pSkin = new Skin::TexturedBase(pRenderer);
		pSkin->Init(L"GModDefault.png");

		// Create a dummy canvas that will be resized later
		pCanvas = new Controls::Canvas(pSkin);
		pCanvas->SetSize(1, 1);

		// Detour FWindowsViewport::ProcessDeferredMessage
		SETUP_SIMPLE_DETOUR(detProcessDeferredMessage, BL2SDK::pProcessDeferredMessage, hkProcessDeferredMessage);
		detProcessDeferredMessage.Attach();

		// Detour Gwen control destructor so we can let Lua know when controls are deleted
		SETUP_SIMPLE_DETOUR(detGwenDestructor, BL2SDK::pGwenDestructor, hkGwenDestructor);
		detGwenDestructor.Attach();

		// Detour FWindowsViewport::Resize to resize the canvas
		SETUP_SIMPLE_DETOUR(detViewportResize, BL2SDK::pViewportResize, hkViewportResize);
		detViewportResize.Attach();
	}

	void UpdateCanvas(int x, int y)
	{
		Logging::LogF("[Gwen] Updating canvas size (%dx%d)\n", x, y);
		pCanvas->SetSize(x, y);
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
		GWEN_WINDOW,
		GWEN_HORIZONTALSLIDER,
		GWEN_COMBOBOX
	};

	FFI_EXPORT Controls::Base* LUAFUNC_CreateNewControl(GwenControls controlNum, Controls::Base* parent)
	{
		if(parent == NULL)
		{
			parent = pCanvas;
		}
		Controls::Base* control = NULL;

		if(controlNum == GWEN_BUTTON)
		{
			control = new Controls::Button(parent);
		}
		else if(controlNum == GWEN_WINDOW)
		{
			Controls::WindowControl* wnd = new Controls::WindowControl(parent);
			wnd->SetDeleteOnClose(true);
			control = wnd;
		}
		else if(controlNum == GWEN_HORIZONTALSLIDER)
		{
			control = new Controls::HorizontalSlider(parent);
		}
		else if(controlNum == GWEN_COMBOBOX)
		{
			control = new Controls::ComboBox(parent);
		}
		
		return control;
	}

	FFI_EXPORT TextObject* LUAFUNC_NewTextObject(const char* str)
	{
		return new TextObject(str);
	}

	FFI_EXPORT void LUAFUNC_DestroyTextObject(TextObject* obj)
	{
		delete obj;
	}

	FFI_EXPORT const char* LUAFUNC_GetTextObjectString(TextObject& obj)
	{
		return obj.c_str();
	}

	FFI_EXPORT void LUAFUNC_SetWindowTitle(Controls::WindowControl* window, const char* str)
	{
		window->SetTitle(str);
	}

	FFI_EXPORT void LUAFUNC_AddGwenCallback(Controls::Base* control, int offset, Event::Handler::Function callback)
	{
		Event::Caller* eh = (Event::Caller*)((int)control + offset);
		eh->Add(control, callback);
	}

	FFI_EXPORT void LUAFUNC_RemoveGwenCallback(Controls::Base* control, int offset, Event::Handler::Function callback)
	{
		Event::Caller* eh = (Event::Caller*)((int)control + offset);
		eh->RemoveHandler(control);
	}

	FFI_EXPORT void LUAFUNC_SetDestructorCallback(tGwenBaseDestructorHook callback)
	{
		Logging::LogF("[Gwen] Destructor callback set to 0x%p\n", callback);
		destructorHook = callback;
	}

	FFI_EXPORT int LUAFUNC_GetCanvasW()
	{
		return pCanvas->GetSize().x;
	}

	FFI_EXPORT int LUAFUNC_GetCanvasH()
	{
		return pCanvas->GetSize().y;
	}

	CON_COMMAND(CleanupCanvas)
	{
		pCanvas->RemoveAllChildren();
	}
}
