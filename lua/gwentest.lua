-- gwen test
local ffi = require("ffi")

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
	timeSlider.OnValueChanged = function(panel)
		dnc:SetTimeOfDay(panel:GetFloatValue())
	end

	local dayButton = gwen.CreateControl("Button", window)
	dayButton:SetText("Set time to Day")
	dayButton:SetSize(50, 40)
	dayButton:Dock(POS_TOP)
	dayButton.OnPress = function(panel)
		dnc:SetTimeOfDay(0)
	end

	local nightButton = gwen.CreateControl("Button", window)
	nightButton:SetText("Set time to Night")
	nightButton:SetSize(50, 40)
	nightButton:Dock(POS_TOP)
	nightButton.OnPress = function(panel)
		dnc:SetTimeOfDay(50)
	end
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
		pc:ClientGotoState("PlayerFlying")

		pawn.AccelRate = 20000
		pawn.AirSpeed = 3000

		pawn:CheatGhost()
	end
end

function ToggleNoclipWithPC(pc)
	print("Toggling Noclip")

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
		pc:ClientGotoState("PlayerFlying")

		pawn.AccelRate = 20000
		pawn.AirSpeed = 3000

		pawn:CheatGhost()
	end
end

function AddKeyHook()
	engineHook.Add(engine.Classes.UWillowGameViewportClient.funcs.InputKey, "NoclipKeyHook", function(caller, args)
		local key = args.Key
		local event = args.EventType

		if key == "V" and event == enums.EInputEvent.IE_Pressed then
			ToggleNoclip()
		end
	end)
end

function RemoveKeyHook()
	engineHook.Remove(engine.Classes.UWillowGameViewportClient.funcs.InputKey, "NoclipKeyHook")
end

function Brap()
	local endTrace = LocalPlayer():GetAxes(LocalPlayer().Rotation)
	local startTrace = LocalPlayer().Pawn.Mesh:GetBoneLocation("Head", 0)

	endTrace.X = (endTrace.X * 30000) + startTrace.X
	endTrace.Y = (endTrace.Y * 30000) + startTrace.Y
	endTrace.Z = (endTrace.Z * 30000) + startTrace.Z

	local ret = LocalPlayer():Trace(endTrace, startTrace, true)
	print(ret)

	if NotNull(ret) then print(ret:GetFullName()) end

	if ret == nil then return nil else return ret end
end

function SetKillDist()
	for i=0,(engine.Objects.Count-1) do
		local obj = engine.Objects:Get(i)
		if IsNull(obj) then goto continue end
		if not obj:IsA(engine.Classes.AWillowBoundaryTurret) then goto continue end

		obj.KillDistance = 99999999

		::continue::
	end
end

function GetStackTrace(frame)
	local currentFrame = frame
	while currentFrame ~= nil do
		if currentFrame.Node ~= nil then
			print(currentFrame.Node:GetFullName())
		else
			print("Node was nil!")
		end
		currentFrame = currentFrame.PreviousFrame
	end
end

function GetSlotChanceBehavior(slot)
	local sequences = slot.InteractiveObjectDefinition.BehaviorProviderDefinition.BehaviorSequences
	for _,seq in pairs(sequences) do
		local behavdata = seq.BehaviorData2
		for _,v in pairs(behavdata) do
			local behav = v.Behavior
			if behav:IsA(engine.Classes.UBehavior_RandomBranch) then
				if behav.Conditions.Count == 12 then
					return behav
				end
			end
		end
	end

	return nil
end

function PullData(obj)
	--[[
	0	40 COMMON
	1	30 UNCOMMON
	2	3 RARE
	3	0.30000001192093 VERYRARE
	4	0.029999999329448 LEGENDARY
	5	5 ERID1
	6	1.5 ERID2
	7	0.44999998807907 ERID3
	8	50 CASH
	9	15 GRENADE
	10	10 SKIN
	11	40 NOTHING
	]]

	local randBehav = GetSlotChanceBehavior(obj)
	if randBehav == nil then return end

	for k,v in pairs(randBehav.Conditions) do
		print(k, v)
	end
end


function AddSpawnHook()
	scriptHook.Remove(engine.Classes.AActor.funcs.Spawn, "SpawnHook")
	scriptHook.AddRaw(engine.Classes.AActor.funcs.Spawn, "SpawnHook", function(Object, Stack, Result, Function)
		print("==================")
		print(Object:GetFullName())
		print("==================")
		GetStackTrace(Stack)
	end)

	engineHook.Remove(engine.Classes.AActor.funcs.Spawn, "SpawnHook")
	engineHook.Add(engine.Classes.AActor.funcs.Spawn, "SpawnHook", function(caller, args)
		print(caller:GetFullName())
	end)
end

function CanEnterVehicleHook()
	engineHook.Remove(engine.Classes.AWillowVehicle.funcs.CanDrive, "CEVHook")
	engineHook.Add(engine.Classes.AWillowVehicle.funcs.CanDrive, "CEVHook", function(caller, args)
		print("Engine hook called, god damn")
	end)

	scriptHook.Remove(engine.Classes.AWillowVehicle.funcs.CanDrive, "CEVHook")
	scriptHook.AddRaw(engine.Classes.AWillowVehicle.funcs.CanDrive, "CEVHook", function(Object, Stack, Result, Function)
		Result = ffi.cast("unsigned long*", Result)
		Result[0] = 1
		Stack:SkipFunction()

		print("Result modified")
		return true
	end)
end

function SpawnTest()
	--[[
	local endTrace = LocalPlayer():GetAxes(LocalPlayer().Rotation)
	local startTrace = LocalPlayer().Pawn.Mesh:GetBoneLocation("Head", 0)

	endTrace.X = (endTrace.X * 30000) + startTrace.X
	endTrace.Y = (endTrace.Y * 30000) + startTrace.Y
	endTrace.Z = (endTrace.Z * 30000) + startTrace.Z

	local ret, HitLocation = LocalPlayer():Trace(endTrace, startTrace, true)
	]]

	spawned = LocalPlayer():Spawn(engine.Classes.AWillowVehicle_WheeledVehicle, nil, nil, LocalPlayer().Pawn.Mesh:GetBoneLocation("Head", 0), nil, engine.Objects:Get(202747), nil)

	print(spawned)
	print(spawned.Mesh)

end