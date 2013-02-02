local os = os
local string = string
local print = print

local timers = {}

module("profiling")

function StartTimer(id, name)
	if timers[id] ~= nil then
		print("[Profiling] Warning: Timer '" .. name .. "' not stopped")
	end

	timers[id] = { name, os.clock() }
end

function StopTimer(id)
	local timer = timers[id]
	if timer ~= nil then
		local elapsed = os.clock() - timer[2]
		print(string.format("[Profiling] %s took %.3f seconds", timer[1], elapsed))
		timers[id] = nil
	else
		print("[Profiling] Warning: Timer '" .. id .. "' not started")
	end
end