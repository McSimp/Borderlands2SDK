local ffi = require("ffi")

ffi.cdef[[
typedef void (__thiscall *tGwen_Controls_WindowControl_SetClosable) (GwenControl*, bool);
void LUAFUNC_SetWindowTitle(GwenControl* window, const char* str);
]]

local WindowControl = table.copy(gwen.meta.ResizableControl)
WindowControl.__index = WindowControl

function WindowControl:SetTitle(title)
	ffi.C.LUAFUNC_SetWindowTitle(self.control, title)
end

function WindowControl:SetClosable(closeable)
	local func = gwen.GetVFunc(self.control, 177, "tGwen_Controls_WindowControl_SetClosable")
	func(self.control, closeable)
end

gwen.meta.WindowControl = WindowControl

--[[
VMT dump from IDA
175: public: virtual void __thiscall Gwen::Controls::WindowControl::SetTitle(class std::basic_string<char, struct std::char_traits<char>, class std::allocator<char>>)
177: public: virtual void __thiscall Gwen::Controls::WindowControl::SetClosable(bool)
]]
