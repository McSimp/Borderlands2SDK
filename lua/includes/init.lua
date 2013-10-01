--require("jit.v")
--jit.v.on("jitv.txt")

-- Load helper functions
require("base")

-- Profiling library
require("profiling")

-- Flags
require("flags")

-- OO Helpers
oo = require("oo")

-- Import data structures
include("structs/base.lua")
include("classes/base.lua")

-- Add load base types
require("FName")
require("TArray")
require("FString")
require("UObject")
require("FFrame")

require("enums")

-- Load engine functions
require("engine")

local function NeedsSDKGenerated()
	local generateSDK = true

	if file.Exists("sdkgen/version.lua") then
		include("../sdkgen/version.lua")

		if SDKGEN_ENGINE_VERSION == bl2sdk.engineVersion and
		SDKGEN_CHANGELIST_NUMBER == bl2sdk.changeListNumber then
			generateSDK = false
		end
	end

	return generateSDK
end

-- Security
package.preload.ffi = nil
package.loaders[3] = nil
package.loaders[4] = nil

if NeedsSDKGenerated() then
	-- Log calls to the slow object index if we're generating the SDK
	engine.LogObjectIndex = true
	engine.Initialize()
	include("sdkgen/sdkgen.lua")
else
	file = nil
	
	include("../sdkgen/loader.lua")
	engine.Initialize()

	-- Some convenience MTs for engine types
	require("FColor")

	require("engineHook")
	require("scriptHook")

	require("command")
	include("luacommands.lua")

	require("canvas")

	-- package.loaded.ffi.cdef = nil -- No more defining

	function OnShutdown()
		scriptHook.RemoveAll()
		engineHook.RemoveAll()
	end
end

--jit.v.off()
