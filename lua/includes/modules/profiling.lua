local os = os
local string = string
local print = print
local collectgarbage = collectgarbage

local timers = {}
local memTracks = {}

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

function TrackMemory(id, name)
	if memTracks[id] ~= nil then
		print("[Profiling] Warning: Memory tracker '" .. name .. "' overwritten")
	end

	memTracks[id] = { name, collectgarbage("count") }
end

function GetMemoryUsage(id)
	local memTrack = memTracks[id]
	if memTrack ~= nil then
		local elapsed = collectgarbage("count") - memTrack[2]
		print(string.format("[Profiling] %s used %.3f kB mem", memTrack[1], elapsed))
		memTracks[id] = nil
	else
		print("[Profiling] Warning: Memory tracker '" .. id .. "' not initialized")
	end
end