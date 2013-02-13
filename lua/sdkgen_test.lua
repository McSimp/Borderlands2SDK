g_TArrayTypes = {}

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

include("sdkgen/TArrays.lua")

for _,pkg in ipairs(packages) do
	profiling.TrackMemory("loadpackage", "Loading " .. pkg)
	include("sdkgen/consts/" .. pkg .. ".lua")
	include("sdkgen/enums/" .. pkg .. ".lua")
	include("sdkgen/structs/" .. pkg .. ".lua")
	include("sdkgen/classes/" .. pkg .. ".lua")
	profiling.GetMemoryUsage("loadpackage")
end

print("[SDKGen] Generated SDK loaded")
