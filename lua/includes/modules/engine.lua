local ffi = require("ffi")

require("FName")
require("TArray")
require("UObject")

ffi.cdef[[
	struct UField_Data {
		struct UField* Next;
	};

	struct UField {
		struct UObject_Data UObject;
		struct UField_Data UField;
	};

	struct UStruct_Data {
		unsigned char Unknown1[0x8];
		struct UField* SuperField;
		struct UField* Children;
		unsigned short PropertySize;
		unsigned short Unknown2;
		unsigned char Unknown3[0x38];
	};

	struct UStruct {
		struct UObject_Data UObject;
		struct UField_Data UField;
		struct UStruct_Data UStruct;
	};

	struct UClass_Data {
		unsigned char Unknown[0x100];
	};

	struct UClass {
		struct UObject_Data UObject;
		struct UField_Data UField;
		struct UStruct_Data UStruct;
		struct UClass_Data UClass;
	};
]]

function NotNull(data)
	return data ~= nil
end

function IsNull(data)
	return data == nil
end

local TArray = TArray
local UObject = UObject
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

UObject.StaticClass = FindClassSafe("Class Core.Object")
