local ffi = require("ffi")
local bit = require("bit")

local TArray = TArray
local IsNull = IsNull
local error = error
local g_loadedClasses = g_loadedClasses
local g_TArrayTypes = g_TArrayTypes
local print = print
local string = string
local UObject = UObject
local os = os
local PtrToNum = PtrToNum
local profiling = profiling
local enums = enums
local debug = debug
local type = type
local tostring = tostring
local pairs = pairs

module("engine")

local OBJECT_HASH_BINS = 32*1024

Objects = TArray.Create("struct UObject*", ffi.cast("struct TArray*", 0x19C6DC0))
Names = TArray.Create("struct FNameEntry*", ffi.cast("struct TArray*", 0x19849E4))
ObjHash = ffi.cast(ffi.typeof("struct UObject**"), 0x019A6CF8)

_ClassesInternal = {}
Classes = {}
local BaseObjFuncs = UObject.BaseFuncs

local TArrayMT = TArray.BaseMT

local function FindObjectWithClass(objectName, class)

	for i=0,(Objects.Count-1) do

		local obj = Objects:Get(i)
		if IsNull(obj) then goto continue end
		if not obj:IsA(class) then goto continue end

		if obj:GetFullName() == objectName then
			return obj
		end

		::continue::
	end

	return nil

end

function FindObject(objectName, class)

	if class ~= nil then
		return FindObjectWithClass(objectName, class)
	end

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

	local obj

	if Classes.UClass ~= nil then
		obj = FindObjectWithClass(className, Classes.UClass)
	else
		obj = FindObject(className)
	end
	
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

function GetObjectHash(objName)
	return bit.band(bit.bxor(objName.Index, objName.Number), OBJECT_HASH_BINS - 1)
end

local function GenerateDataMT(name, funcs)
	return function(self, k)
		print("DataMT: " .. k .. " " .. name)
		return nil
		--return funcs[k] -- Should return nil if not found
	end
end

local function NilIndex()
	return nil
end

local function UObjectIndex(self, k)
	-- First check the base functions
	if BaseObjFuncs[k] ~= nil then return BaseObjFuncs[k] end

	-- Get the actual class information for this object
	local classInfo = _ClassesInternal[PtrToNum(self.UObject.Class)]

	print("Object is actually " .. classInfo["name"])

	-- Check that we actually have the info for this class
	if classInfo == nil then
		print(debug.traceback())
		error(string.format("Class info not found: Name = %s, Ptr = 0x%X",
			self.UObject.Class:GetCName(),
			PtrToNum(self.UObject.Class)
		))
	end

	-- Cast this object to the right type
	self = ffi.cast(classInfo.ptrType, self)

	-- Since we have casted, check the actual class type first
	-- Then while this class has a base class, check that.
	local base = classInfo
	while base do
		print("Trying base " .. base["name"])
		if self[base["name"]][k] ~= nil then
			print("not nil returning")
			return self[base["name"]][k]
		else
			print("doing the next base")
			base = base["base"]
		end
	end

	return nil
end

function MakeEnum(name, identifiers)
	local enum = {}
	for i=1,#identifiers do
		enum[identifiers[i]] = (i-1)
	end

	enums[name] = enum -- TODO: Maybe there's a better way
end

local UObjectDataMT = { __index = NilIndex }
local UObjectMT = { __index = UObjectIndex }

local function InitializeClasses()
	for name,_ in pairs(g_loadedClasses) do
		ffi.metatype("struct " .. name, UObjectMT) -- Everything is a UObject, so set its MT on everything
	end

	local count = 0

	for name,class in pairs(g_loadedClasses) do
		-- name = class name, 1 = Full Name/index, 2 = Base name, 3 = func table

		print(name .. " has base " .. class[2])
		local members = {
			name = name,
			base = Classes[class[2]],
			ptrType = ffi.typeof("struct " .. name .. "*"),
			funcs = class[3]
		}

		-- If it's a string, it's a full name and we need to search.
		if type(class[1]) == "string" then
			members.static = FindClassSafe(class[1])
		else -- Otherwise it's just an offset and we can just get it out of the array
			members.static = Objects:Get(class[1])
			if IsNull(members.static) then
				error("Failed to find class '" .. name .. "'")
			end
		end

		_ClassesInternal[PtrToNum(members.static)] = members
		Classes[name] = members

		-- Makes the _Data types return nil if member not found, or a function
		ffi.metatype("struct " .. name .. "_Data", { __index = GenerateDataMT(name, members.funcs) })

		count = count + 1
	end

	print(string.format("[Lua] %d classes initialized", count))

	g_loadedClasses = nil
end

local function InitializeTArrays()
	for i=1,#g_TArrayTypes do
		ffi.metatype("struct TArray_" .. g_TArrayTypes[i] .. "_", TArrayMT)
	end

	print(string.format("[Lua] %d TArray types initialized", #g_TArrayTypes))

	g_TArrayTypes = nil
end

function Initialize()
	profiling.StartTimer("engineinit", "Engine Initialization")

	print("[Lua] Initializing engine classes...")

	-- Initialize metatables on all classes
	InitializeClasses()

	-- Add the TArray metatable to all the template types
	InitializeTArrays()

	profiling.StopTimer("engineinit")
end