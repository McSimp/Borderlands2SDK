-- gwen test

function GwenTest()
	local window = gwen.CreateControl("WindowControl")
	window:SetTitle("Buttons and whatnot")
	window:SetPos(50, 50)
	window:SetSize(250, 250)
	window:MakeModal()
	print(window:_GetInternalControl())

	local button1 = gwen.CreateControl("Button", window)
	button1:SetText("Button1")
	button1:SetSize(50, 100)
	button1:Dock(8)
	button1.OnPress = function(panel) print("Button1 pressed") end
	print(button1:_GetInternalControl())

	local button2 = gwen.CreateControl("Button", window)
	button2:SetText("Button2")
	button2:SetSize(50, 100)
	button2:Dock(8)
	button2.OnPress = function(panel) print("Button2 pressed") end
	button2.OnHoverEnter = function(panel) print("Button2 hovered") end
	button2.OnHoverEnter = nil
	button2.SomeDataIWant = "Hello World!"
	button2.OnHoverEnter = function(panel) print("Button2 hovered new!") end
	print(button2:_GetInternalControl())

	local slider = gwen.CreateControl("HorizontalSlider", window)
	slider:SetSize(50, 20)
	slider:Dock(8)
	slider.OnValueChanged = function(panel) print(panel:GetFloatValue()) end
	print(slider:_GetInternalControl())
end

function TimeControllerUI()
	local dnc = engine.FindObjectExactClass("WillowSeqAct_DayNightCycle PersistentLevel.Main_Sequence.WillowSeqAct_DayNightCycle", engine.Classes.UWillowSeqAct_DayNightCycle)
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

function SetDNCycleRate(rate)
	local gd = engine.FindObjectExactClass("GlobalsDefinition GD_Globals.General.Globals", engine.Classes.UGlobalsDefinition)
	gd.DayNightCycleRate = rate

	local ri = engine.FindObjectExactClass("WillowGameReplicationInfo TheWorld.PersistentLevel.WillowGameReplicationInfo", engine.Classes.AWillowGameReplicationInfo)
	ri.DayNightCycleRate = rate
	ri.DayNightCycleRateBaseValue = rate

	local dnc = engine.FindObjectExactClass("WillowSeqAct_DayNightCycle PersistentLevel.Main_Sequence.WillowSeqAct_DayNightCycle", engine.Classes.UWillowSeqAct_DayNightCycle)
	dnc.PlayRate = rate

	print("Changed rate to " .. tostring(rate))
end

function ToggleNoclip()
	print("Toggling Noclip")

	local pc = LocalPlayer()
	local pawn = pc.AcknowledgedPawn
	
	if pc.bCheatFlying then
		pc.bCheatFlying = false
		pawn:CheatWalk()
		pc:Restart(false)

		pawn.AccelRate = 2048
		pawn.AirSpeed = 440
	else
		pawn:CheatFly()
		pc.bCheatFlying = true
		pc:GotoState("PlayerFlying")

		pawn.AccelRate = 20000
		pawn.AirSpeed = 3000

		pawn:CheatGhost()
	end
end

function AddKeyHook()
	engineHook.Add(engine.Classes.UWillowGameViewportClient.funcs.InputKey, "NoclipKeyHook", function(cid, key, event)
		if key:GetName() == "V" and event == enums.EInputEvent.IE_Pressed then
			ToggleNoclip()
		end
	end)
end

function RemoveKeyHook()
	engineHook.Remove(engine.Classes.UWillowGameViewportClient.funcs.InputKey, "NoclipKeyHook")
end

function Brap()
	local boneName = LocalPlayer().Pawn.Mesh:GetBoneName(6)
	local startTrace = LocalPlayer().Pawn.Mesh:GetBoneLocation("Head", 0)

	print(boneName.Index, boneName.Number, boneName:GetName())

	print(startTrace.X, startTrace.Y, startTrace.Z)
end
