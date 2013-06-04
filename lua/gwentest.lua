-- gwen test
include("includes/gwen/gwen.lua")
--[[
local ffi = require("ffi")

function TestButton()
	local control = ffi.C.LUAFUNC_CreateNewControl(gwen.Controls.Window, nil)

	local windowTest = setmetatable({ control = control }, gwen.meta.WindowControl)
	windowTest:SetTitle("Hello Everynung")
	windowTest:SetPos(50, 50)
	windowTest:SetSize(250, 250)

	local control2 = ffi.C.LUAFUNC_CreateNewControl(gwen.Controls.Button, control)

	local buttonTest = setmetatable({ control = control2 }, gwen.meta.Button)
	buttonTest:SetText("Now in the JewSex channel")
	buttonTest:SetSize(50, 100)
	buttonTest:Dock(8)
	buttonTest:AddOnPress(function(panel) print("Button1 pressed") end)

	local control3 = ffi.C.LUAFUNC_CreateNewControl(gwen.Controls.Button, control)

	local buttonTest = setmetatable({ control = control3 }, gwen.meta.Button)
	buttonTest:SetText("Wilko is a baguette")
	buttonTest:SetSize(50, 100)
	buttonTest:Dock(8)
	buttonTest:AddOnPress(function(panel) print("Button2 pressed") end)

end
]]
function GwenTest()
	local window = gwen.CreateControl("WindowControl")
	window:SetTitle("Buttons and whatnot")
	window:SetPos(50, 50)
	window:SetSize(250, 250)
	print(window:_GetInternalControl())

	local button1 = gwen.CreateControl("Button", window)
	button1:SetText("Button1")
	button1:SetSize(50, 100)
	button1:Dock(8)
	button1:AddOnPress(function(panel) print("Button1 pressed") end)
	print(button1:_GetInternalControl())

	local button2 = gwen.CreateControl("Button", window)
	button2:SetText("Button2")
	button2:SetSize(50, 100)
	button2:Dock(8)
	button2:AddOnPress(function(panel) print("Button2 pressed") end)
	print(button2:_GetInternalControl())

	local slider = gwen.CreateControl("HorizontalSlider", window)
	slider:SetSize(50, 20)
	slider:Dock(8)
	slider:AddOnValueChanged(function(panel) print(panel:GetFloatValue()) end)
	print(slider:_GetInternalControl())
end

function TimeControllerUI()
	local dnc = engine.FindObject("WillowSeqAct_DayNightCycle PersistentLevel.Main_Sequence.WillowSeqAct_DayNightCycle", engine.Classes.UWillowSeqAct_DayNightCycle)
	if dnc == nil then error("DNC was null") end

	local window = gwen.CreateControl("WindowControl")
	window:SetTitle("Time Controller")
	window:SetPos(10, gwen.ScrH() - 160)
	window:SetSize(400, 150)

	local timeSlider = gwen.CreateControl("HorizontalSlider", window)
	timeSlider:SetSize(50, 30)
	timeSlider:Dock(POS_TOP)
	timeSlider:SetRange(0, dnc.InterpData.InterpLength)
	timeSlider:AddOnValueChanged(function(panel)
		dnc:SetTimeOfDay(panel:GetFloatValue())
	end)

	local dayButton = gwen.CreateControl("Button", window)
	dayButton:SetText("Set time to Day")
	dayButton:SetSize(50, 40)
	dayButton:Dock(POS_TOP)
	dayButton:AddOnPress(function(panel)
		dnc:SetTimeOfDay(0)
	end)

	local nightButton = gwen.CreateControl("Button", window)
	nightButton:SetText("Set time to Night")
	nightButton:SetSize(50, 40)
	nightButton:Dock(POS_TOP)
	nightButton:AddOnPress(function(panel)
		dnc:SetTimeOfDay(50)
	end)
end
