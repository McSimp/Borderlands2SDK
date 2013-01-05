-- Import data structures
include("structs/base.lua")
include("classes/base.lua")

-- Load helper functions
require("base")

-- Add metatables to base types
require("FName")
require("TArray")

-- Load engine functions
require("engine")

-- Load classes
require("UObject")
require("UClass")
