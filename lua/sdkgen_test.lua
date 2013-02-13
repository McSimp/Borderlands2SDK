g_TArrayTypes = {}

include("sdkgen/TArrays.lua")

local packages = { 
	"Core",
	"Engine",
	"GameFramework",
	"GFxUI",
	"GearboxFramework",
	"IpDrv",
	"XAudio2",
	"AkAudio",
	"WinDrv",
	"OnlineSubsystemSteamworks",
	"WillowGame"
}

--[[
local packages = { 
	"AkAudio",
	"Core",
	"Engine",
	"GameFramework",
	"GearboxFramework",
	"GFxUI",
	"IpDrv",
	"OnlineSubsystemSteamworks",
	"WillowGame",
	"WinDrv",
	"XAudio2"
}
]]

for _,v in ipairs(packages) do
	profiling.TrackMemory("loadpackage", "Loading " .. v)
	include("sdkgen/consts/" .. v .. ".lua")
	include("sdkgen/enums/" .. v .. ".lua")
	include("sdkgen/structs/" .. v .. ".lua")
	include("sdkgen/classes/" .. v .. ".lua")
	profiling.GetMemoryUsage("loadpackage")
end

print("Generated SDK loaded")
