function RunTrace()
	local endTrace = LocalPC():GetAxes(LocalPC().Rotation)
	local startTrace = LocalPC().Pawn.Mesh:GetBoneLocation("Head", 0)

	endTrace.X = (endTrace.X * 30000) + startTrace.X
	endTrace.Y = (endTrace.Y * 30000) + startTrace.Y
	endTrace.Z = (endTrace.Z * 30000) + startTrace.Z

	local ret = LocalPC():Trace(endTrace, startTrace, true)

	if NotNull(ret) then print(ret:GetFullName()) else print("NULL") end

	if ret == nil then return nil else return ret end
end

function ToggleNoclip()
	print("Toggling Noclip")

	local pc = LocalPC()
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
	engineHook.Add("UWillowGameViewportClient", "InputKey", "TraceKeyHook", function(caller, args)
		local key = args.Key
		local event = args.EventType

		if key == "P" and event == enum.EInputEvent.IE_Pressed then
			RunTrace()
		end
	end)

	engineHook.Add("UWillowGameViewportClient", "InputKey", "NoclipKeyHook", function(caller, args)
		local key = args.Key
		local event = args.EventType

		if key == "V" and event == enum.EInputEvent.IE_Pressed then
			ToggleNoclip()
		end
	end)
end

function RemoveKeyHook()
	engineHook.Remove("UWillowGameViewportClient", "InputKey", "TraceKeyHook")
	engineHook.Remove("UWillowGameViewportClient", "InputKey", "NoclipKeyHook")
end

function SpawnTest()
	spawned = LocalPC():Spawn(engine.Classes.AWillowVehicle_WheeledVehicle, nil, nil, LocalPC().Pawn.Mesh:GetBoneLocation("Head", 0), nil, engine.Objects[179867], nil)
	print(spawned)
	print(spawned.Mesh)
end
