local ffi = require("ffi")

ffi.cdef[[
typedef bool (__thiscall *tGwen_Controls_Button_IsDepressed) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Button_SetDepressed) (GwenControl*, bool);
typedef void (__thiscall *tGwen_Controls_Button_SetIsToggle) (GwenControl*, bool);
typedef bool (__thiscall *tGwen_Controls_Button_IsToggle) (GwenControl*);
typedef bool (__thiscall *tGwen_Controls_Button_GetToggleState) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Button_SetToggleState) (GwenControl*, bool);
typedef void (__thiscall *tGwen_Controls_Button_Toggle) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Button_SetImage) (GwenControl*, TextObject const &, bool);
typedef void (__thiscall *tGwen_Controls_Button_SetImageAlpha) (GwenControl*, float);
]]

local Button = table.copy(gwen.meta.Label)
Button.__index = Button

function Button:IsDepressed()
	local func = gwen.GetVFunc(self.control, 199, "tGwen_Controls_Button_IsDepressed")
	return func(self.control)
end

function Button:SetDepressed(b)
	local func = gwen.GetVFunc(self.control, 200, "tGwen_Controls_Button_SetDepressed")
	func(self.control, b)
end

function Button:SetIsToggle(b)
	local func = gwen.GetVFunc(self.control, 201, "tGwen_Controls_Button_SetIsToggle")
	func(self.control, b)
end

function Button:IsToggle()
	local func = gwen.GetVFunc(self.control, 202, "tGwen_Controls_Button_IsToggle")
	return func(self.control)
end

function Button:GetToggleState()
	local func = gwen.GetVFunc(self.control, 203, "tGwen_Controls_Button_GetToggleState")
	return func(self.control)
end

function Button:SetToggleState(b)
	local func = gwen.GetVFunc(self.control, 204, "tGwen_Controls_Button_SetToggleState")
	func(self.control, b)
end

function Button:Toggle()
	local func = gwen.GetVFunc(self.control, 205, "tGwen_Controls_Button_Toggle")
	func(self.control)
end

function Button:SetImage(name, center)
	if center == nil then center = false end

	local func = gwen.GetVFunc(self.control, 206, "tGwen_Controls_Button_SetImage")
	
	local obj = gwen.GetTextObject(name)
	func(self.control, obj, center)
	gwen.FreeTextObject(obj)
end

function Button:SetImageAlpha(multiply)
	local func = gwen.GetVFunc(self.control, 207, "tGwen_Controls_Button_SetImageAlpha")
	func(self.control, multiply)
end

if _DEBUG then
	Button.Events.OnPress = 244
	Button.Events.OnRightPress = 256
	Button.Events.OnDown = 268
	Button.Events.OnUp = 280
	Button.Events.OnDoubleClick = 292
	Button.Events.OnToggle = 304
	Button.Events.OnToggleOn = 316
	Button.Events.OnToggleOff = 328
else
	Button.Events.OnPress = 216
	Button.Events.OnRightPress = 224
	Button.Events.OnDown = 232
	Button.Events.OnUp = 240
	Button.Events.OnDoubleClick = 248
	Button.Events.OnToggle = 256
	Button.Events.OnToggleOn = 264
	Button.Events.OnToggleOff = 272
end

gwen.meta.Button = Button

--[[
VMT dump from IDA
#197: public: virtual void __thiscall Gwen::Controls::Button::OnPress(void)
#198: public: virtual void __thiscall Gwen::Controls::Button::OnRightPress(void)
199: public: virtual bool __thiscall Gwen::Controls::Button::IsDepressed(void)const
200: public: virtual void __thiscall Gwen::Controls::Button::SetDepressed(bool)
201: public: virtual void __thiscall Gwen::Controls::Button::SetIsToggle(bool)
202: public: virtual bool __thiscall Gwen::Controls::Button::IsToggle(void)const
203: public: virtual bool __thiscall Gwen::Controls::Button::GetToggleState(void)const
204: public: virtual void __thiscall Gwen::Controls::Button::SetToggleState(bool)
205: public: virtual void __thiscall Gwen::Controls::Button::Toggle(void)
206: public: virtual void __thiscall Gwen::Controls::Button::SetImage(class Gwen::TextObject const &, bool)
207: public: virtual void __thiscall Gwen::Controls::Button::SetImageAlpha(float)
]]
