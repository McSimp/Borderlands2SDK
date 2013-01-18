local ffi = require("ffi")

local TArray = TArray
local IsNull = IsNull
local error = error
local loadedClasses = loadedClasses
local print = print
local string = string
local UObject = UObject
local os = os
local PtrToNum = PtrToNum

module("engine")

Objects = TArray("struct UObject*", ffi.cast("struct TArray*", 0x19C6DC0))
Names = TArray("struct FNameEntry*", ffi.cast("struct TArray*", 0x19849E4))
_ClassesInternal = {}
Classes = {}

function FindObject(objectName)

	for i=0,(Objects.Count-1) do

		local obj = Objects:Get(i)
		if IsNull(obj) then goto continue end

		if obj:GetFullName() == objectName then
			return obj
		end

		::continue::
	end

	return nil

end

function FindClass(className)

	local obj = FindObject(className)
	
	if IsNull(obj) then
		return nil
	else
		return ffi.cast("struct UClass*", obj)
	end

end

function FindClassSafe(className)

	local result = FindClass(className)

	if IsNull(result) then
		error("Failed to find class '" .. className .. "'")
	else
		return result
	end

end

local function NilIndex()
	return nil
end

function Initialize()
	local start = os.clock()

	print("[Lua] Initializing engine classes...")

	for i=1,#loadedClasses do

		ffi.metatype("struct " .. loadedClasses[i][1], UObject.MetaTable) -- Everything is a UObject, so set its MT on everything
		ffi.metatype("struct " .. loadedClasses[i][1] .. "_Data", { __index = NilIndex }) -- Makes the _Data types return nil if member not found

	end

	for i=1,#loadedClasses do

		local classPtr = FindClassSafe(loadedClasses[i][2])
		local members = { name = loadedClasses[i][1], static = classPtr, base = Classes[loadedClasses[i][3]], funcs = {} }

		_ClassesInternal[PtrToNum(classPtr)] = members
		Classes[loadedClasses[i][1]] = members

	end

	print(string.format("[Lua] %d classes initialized", #loadedClasses))

	loadedClasses = nil

	print(string.format("elapsed time: %.3f", os.clock() - start))
end