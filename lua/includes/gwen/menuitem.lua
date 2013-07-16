local ffi = require("ffi")

ffi.cdef[[
typedef void (__thiscall *tGwen_Controls_MenuItem_SetCheckable) (GwenControl*, bool);
typedef void (__thiscall *tGwen_Controls_MenuItem_SetChecked) (GwenControl*, bool);
typedef bool (__thiscall *tGwen_Controls_MenuItem_GetChecked) (GwenControl*);
]]

local MenuItem = table.copy(gwen.meta.Button)
MenuItem.__index = MenuItem

function MenuItem:SetCheckable(b)
	local func = gwen.GetVFunc(self.control, 208, "tGwen_Controls_MenuItem_SetCheckable")
	func(self.control, b)
end

function MenuItem:SetChecked(bCheck)
	local func = gwen.GetVFunc(self.control, 209, "tGwen_Controls_MenuItem_SetChecked")
	func(self.control, bCheck)
end

function MenuItem:GetChecked()
	local func = gwen.GetVFunc(self.control, 210, "tGwen_Controls_MenuItem_GetChecked")
	return func(self.control)
end

gwen.meta.MenuItem = MenuItem

--[[
VMT dump from IDA
208: public: virtual void __thiscall Gwen::Controls::MenuItem::SetCheckable(bool)
209: public: virtual void __thiscall Gwen::Controls::MenuItem::SetChecked(bool)
210: public: virtual bool __thiscall Gwen::Controls::MenuItem::GetChecked(void)
]]
