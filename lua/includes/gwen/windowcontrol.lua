local ffi = require("ffi")

ffi.cdef[[
typedef void (__thiscall *tGwen_Controls_WindowControl_SetClosable) (GwenControl*, bool);
typedef void (__thiscall *tGwen_Controls_WindowControl_SetDeleteOnClose) (GwenControl*, bool);
typedef void (__thiscall *tGwen_Controls_WindowControl_MakeModal) (GwenControl*, bool);
typedef void (__thiscall *tGwen_Controls_WindowControl_DestroyModal) (GwenControl*);
void LUAFUNC_SetWindowTitle(GwenControl* window, const char* str);
]]

local WindowControl = table.copy(gwen.meta.ResizableControl)
WindowControl.__index = WindowControl

function WindowControl:SetTitle(title)
	ffi.C.LUAFUNC_SetWindowTitle(self.control, title)
end

function WindowControl:SetClosable(closeable)
	local func = gwen.GetVFunc(self.control, 180, "tGwen_Controls_WindowControl_SetClosable")
	func(self.control, closeable)
end

function WindowControl:SetDeleteOnClose(b)
	local func = gwen.GetVFunc(self.control, 181, "tGwen_Controls_WindowControl_SetDeleteOnClose")
	func(self.control, b)
end

function WindowControl:MakeModal(bDrawBackground)
	if bDrawBackground == nil then bDrawBackground = true end
	local func = gwen.GetVFunc(self.control, 182, "tGwen_Controls_WindowControl_MakeModal")
	func(self.control, bDrawBackground)
end

function WindowControl:DestroyModal()
	local func = gwen.GetVFunc(self.control, 183, "tGwen_Controls_WindowControl_DestroyModal")
	func(self.control)
end

function WindowControl:AddOnWindowClosed(func)
	gwen.AddCallback(self.control, 296, "OnWindowClosed", func)
end

gwen.meta.WindowControl = WindowControl

--[[
VMT dump from IDA
#178: public: virtual void __thiscall Gwen::Controls::WindowControl::SetTitle(class std::basic_string<char, struct std::char_traits<char>, class std::allocator<char>>)
#179: public: virtual void __thiscall Gwen::Controls::WindowControl::SetTitle(class std::basic_string<wchar_t, struct std::char_traits<wchar_t>, class std::allocator<wchar_t>>)
180: public: virtual void __thiscall Gwen::Controls::WindowControl::SetClosable(bool)
181: public: virtual void __thiscall Gwen::Controls::WindowControl::SetDeleteOnClose(bool)
182: public: virtual void __thiscall Gwen::Controls::WindowControl::MakeModal(bool)
183: public: virtual void __thiscall Gwen::Controls::WindowControl::DestroyModal(void)
]]
