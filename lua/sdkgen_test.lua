profiling.TrackMemory("loadconsts", "Loading consts")
include("sdkgen/consts/AkAudio.lua")
include("sdkgen/consts/Core.lua")
include("sdkgen/consts/Engine.lua")
include("sdkgen/consts/GameFramework.lua")
include("sdkgen/consts/GearboxFramework.lua")
include("sdkgen/consts/GFxUI.lua")
include("sdkgen/consts/IpDrv.lua")
include("sdkgen/consts/OnlineSubsystemSteamworks.lua")
include("sdkgen/consts/WillowGame.lua")
include("sdkgen/consts/WinDrv.lua")
include("sdkgen/consts/XAudio2.lua")
profiling.GetMemoryUsage("loadconsts")

profiling.TrackMemory("loadstructs", "Loading structs")
include("sdkgen/structs/AkAudio.lua")
include("sdkgen/structs/Core.lua")
include("sdkgen/structs/Engine.lua")
include("sdkgen/structs/GameFramework.lua")
include("sdkgen/structs/GearboxFramework.lua")
include("sdkgen/structs/GFxUI.lua")
include("sdkgen/structs/IpDrv.lua")
include("sdkgen/structs/OnlineSubsystemSteamworks.lua")
include("sdkgen/structs/WillowGame.lua")
include("sdkgen/structs/WinDrv.lua")
include("sdkgen/structs/XAudio2.lua")
profiling.GetMemoryUsage("loadstructs")

print("Generated SDK loaded")