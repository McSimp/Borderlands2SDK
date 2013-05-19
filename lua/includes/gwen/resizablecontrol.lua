local ffi = require("ffi")

ffi.cdef[[
typedef void (__thiscall *tGwen_Controls_ResizableControl_SetClampMovement) (GwenControl*, bool);
typedef bool (__thiscall *tGwen_Controls_ResizableControl_GetClampMovement) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_ResizableControl_SetMinimumSize) (GwenControl*, GwenPoint const &);
typedef void (__thiscall *tGwen_Controls_ResizableControl_DisableResizing) (GwenControl*);
]]

local ResizableControl = table.copy(gwen.meta.InheritedControl)
ResizableControl.__index = ResizableControl

function ResizableControl:SetClampMovement(shouldClamp)
	local func = gwen.GetVFunc(self.control, 169, "tGwen_Controls_ResizableControl_SetClampMovement")
	func(self.control, shouldClamp)
end

function ResizableControl:GetClampMovement()
	local func = gwen.GetVFunc(self.control, 170, "tGwen_Controls_ResizableControl_GetClampMovement")
	return func(self.control)
end

function ResizableControl:SetMinimumSize(x, y)
	local func = gwen.GetVFunc(self.control, 171, "tGwen_Controls_ResizableControl_SetMinimumSize")
	local point = ffi.new("GwenPoint", x, y)
	func(self.control, point)
end

function ResizableControl:DisableResizing()
	local func = gwen.GetVFunc(self.control, 172, "tGwen_Controls_ResizableControl_DisableResizing")
	func(self.control)
end

gwen.meta.ResizableControl = ResizableControl

--[[
VMT dump from IDA
169: public: virtual void __thiscall Gwen::Controls::ResizableControl::SetClampMovement(bool)
170: public: virtual bool __thiscall Gwen::Controls::ResizableControl::GetClampMovement(void)
171: public: virtual void __thiscall Gwen::Controls::ResizableControl::SetMinimumSize(struct Gwen::Point const &)
172: public: virtual void __thiscall Gwen::Controls::ResizableControl::DisableResizing(void)
#173: public: virtual void __thiscall Gwen::Controls::ResizableControl::OnResized(void)
#174: public: virtual class Gwen::ControlsInternal::Resizer * __thiscall Gwen::Controls::ResizableControl::GetResizer(int)
]]
