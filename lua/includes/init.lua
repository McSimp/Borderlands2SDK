require("jit.v")
jit.v.on("jitv.txt")

-- Load helper functions
require("base")

-- Profiling library
require("profiling")

-- Import data structures
include("structs/base.lua")
include("classes/base.lua")

-- Add load base types
require("FName")
require("TArray")
require("FString")
require("UObject")
require("FFrame")

-- Load engine functions
require("engine")

local generateSDK = false

local function NeedsSDKGenerated()
	engine.LogObjectIndex = generateSDK
	return generateSDK
end

if NeedsSDKGenerated() then
	engine.Initialize()
	include("sdkgen/sdkgen.lua")
else
	include("../sdkgen/loader.lua")
	engine.Initialize()

	require("engineHook")
	require("scriptHook")
end

jit.v.off()