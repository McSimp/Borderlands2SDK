local ffi = require("ffi")

ffi.cdef[[
typedef void (__thiscall *tGwen_Controls_HorizontalSlider_UpdateBarFromValue) (GwenControl*);
]]

local HorizontalSlider = table.copy(gwen.meta.Slider)
HorizontalSlider.__index = HorizontalSlider

function HorizontalSlider:UpdateBarFromValue()
	local func = gwen.GetVFunc(self.control, 183, "tGwen_Controls_HorizontalSlider_UpdateBarFromValue")
	func(self.control)
end

gwen.meta.HorizontalSlider = HorizontalSlider

--[[
VMT dump from IDA
183: public: virtual void __thiscall Gwen::Controls::HorizontalSlider::UpdateBarFromValue(void)
]]
