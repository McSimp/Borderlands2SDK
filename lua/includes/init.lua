require("jit.v")
jit.v.on("jitv.txt")

-- Load helper functions
require("base")

-- Import data structures
include("structs/base.lua")
include("classes/base.lua")

-- Add load base types
require("FName")
require("TArray")
require("UObject")

-- Load engine functions
require("engine")

engine.Initialize()

jit.v.off()