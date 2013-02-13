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

--[[
local function GenerateDataMT(className)
	--local classFuncs = Classes[className]["funcs"]
	return function(self, k)
		--return Classes[className]["funcs"][k] -- Should return nil if not found
		return nil
	end
end
]]

local function NilIndex()
	return nil
end

local function UObjectIndex(self, k)
	-- First check the base functions
	if BaseObjFuncs[k] ~= nil then return BaseObjFuncs[k] end

	-- Get the actual class information for this object
	local classInfo = _ClassesInternal[PtrToNum(self.UObject.Class)]

	-- Check that we actually have the info for this class
	if classInfo == nil then
		print(debug.traceback())
		error("Class info not found")
	end

	-- Cast this object to the right type
	self = ffi.cast(classInfo.ptrType, self)

	-- Since we have casted, check the actual class type first
	-- Then while this class has a base class, check that.
	local base = classInfo
	while base do
		if self[base["name"]][k] ~= nil then 
			return self[base["name"]][k]
		else
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
	for i=1,#g_loadedClasses do
		ffi.metatype("struct " .. g_loadedClasses[i][1] .. "_Data", UObjectDataMT) -- Makes the _Data types return nil if member not found
		ffi.metatype("struct " .. g_loadedClasses[i][1], UObjectMT) -- Everything is a UObject, so set its MT on everything
	end

	for i=1,#g_loadedClasses do
		local class = g_loadedClasses[i] -- 1 = name, 2 = Full Name, 3 = Base name

		local members = {
			name = class[1],
			static = FindClassSafe(class[2]),
			base = Classes[class[3]],
			ptrType = ffi.typeof("struct " .. class[1] .. "*"),
			funcs = {}
		}

		_ClassesInternal[PtrToNum(classPtr)] = members
		Classes[class[1]] = members
	end

	print(string.format("[Lua] %d classes initialized", #g_loadedClasses))

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