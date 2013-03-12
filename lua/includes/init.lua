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

-- Load engine functions
require("engine")

local function NeedsSDKGenerated()
	return false
end

if NeedsSDKGenerated() then
	engine.Initialize()
	include("sdkgen/sdkgen.lua")
else
	include("../sdkgen/loader.lua")
	engine.Initialize()

	require("engineHook")
end

jit.v.off()