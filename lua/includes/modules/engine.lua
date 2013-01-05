local ffi = require("ffi")

local TArray = TArray
local IsNull = IsNull
local error = error

module("engine")

Objects = TArray("struct UObject*", ffi.cast("struct TArray*", 0x19C6DC0))
Names = TArray("struct FNameEntry*", ffi.cast("struct TArray*", 0x19849E4))

function FindClass(className)

	for i=0,(Objects.Count-1) do

		local obj = Objects:Get(i)
		if IsNull(obj) then goto continue end

		if obj.UObject:GetFullName() == className then
			
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