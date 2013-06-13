require("jit.v")
jit.v.on("jitv.txt")

-- Load helper functions
require("base")

-- Profiling library
require("profiling")

-- Flags
require("flags")

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

-- Load Gwen
include("gwen/gwen.lua")

local function NeedsSDKGenerated()
	local generateSDK = true

	local versionFile = io.open("D:\\dev\\bl\\Borderlands2SDK\\bin\\Debug\\lua\\sdkgen\\version.lua", "r")
	if versionFile ~= nil then
		include("../sdkgen/version.lua")

		if SDKGEN_ENGINE_VERSION == bl2sdk.engineVersion and
		SDKGEN_CHANGELIST_NUMBER == bl2sdk.changelistNumber then
			generateSDK = false
		end
	end

	return generateSDK
end

if NeedsSDKGenerated() then
	-- Log calls to the slow object index if we're generating the SDK
	engine.LogObjectIndex = true
	engine.Initialize()
	include("sdkgen/sdkgen.lua")
else
	include("../sdkgen/loader.lua")
	engine.Initialize()

	require("engineHook")
	require("scriptHook")
end

jit.v.off()