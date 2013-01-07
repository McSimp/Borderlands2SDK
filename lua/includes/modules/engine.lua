local ffi = require("ffi")

local TArray = TArray
local IsNull = IsNull
local error = error
local loadedClasses = loadedClasses
local print = print
local string = string
local UObject = UObject

module("engine")

Objects = TArray("struct UObject*", ffi.cast("struct TArray*", 0x19C6DC0))
Names = TArray("struct FNameEntry*", ffi.cast("struct TArray*", 0x19849E4))
Classes = {}

function FindClass(className)

	for i=0,(Objects.Count-1) do

		local obj = Objects:Get(i)
		if IsNull(obj) then goto continue end

		if obj:GetFullName() == className then
			
			return ffi.cast("struct UClass*", obj)

		end

		::continue::
	end

	return nil

end

function FindClassSafe(className)

	local result = FindClass(className)

	if IsNull(result) then
		error("Failed to find class '" .. className .. "'")
	else
		return result
	end

end

function Initialize()

	print("[Lua] Initializing engine classes...")

	for i=1,#loadedClasses do

		ffi.metatype("struct " .. loadedClasses[i][1], UObject.MetaTable) -- Everything is a UObject, so set its MT on everything

	end

	for i=1,#loadedClasses do

		Classes[loadedClasses[i][1]] = { _static = FindClassSafe(loadedClasses[i][2]) }

	end

	print(string.format("[Lua] %d classes initialized", #loadedClasses))

	loadedClasses = nil

end