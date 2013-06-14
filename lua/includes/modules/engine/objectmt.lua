local print = print
local debug = debug
local string = string
local error = error
local PtrToNum = PtrToNum
local setmetatable = setmetatable
local type = type

local ffi = require("ffi")

local _ClassesInternal = engine._ClassesInternal

local LogObjectIndex = false
local BaseObjFuncs = UObject.BaseFuncs
local FuncMT = engine.FuncMT

local UObjectMT = {}

function UObjectMT.__index(self, k)
	-- First check the base functions
	if BaseObjFuncs[k] ~= nil then return BaseObjFuncs[k] end

	if LogObjectIndex then print("Calling UObjectMT.__index", self, k) end

	-- Get the actual class information for this object
	local classInfo = _ClassesInternal[PtrToNum(self.UObject.Class)]

	-- Check that we actually have the info for this class
	if classInfo == nil then
		print(debug.traceback())
		error(string.format("Class info not found: Name = %s, Ptr = 0x%X",
			self.UObject.Class:GetCName(),
			PtrToNum(self.UObject.Class)
		))
	end

	-- Cast this object to the right type
	local obj = ffi.cast(classInfo.ptrType, self)

	-- This seems to be working now. If problems come back, just flip this
	-- Also remember to jit.on() on ALL returns!
	--jit.off()

	-- Since we have casted, check the actual class type first
	-- Then while this class has a base class, check that.
	local baseClass = classInfo
	while baseClass do
		local v = obj[baseClass.name][k]
		if v ~= nil then
			return v
		elseif v == nil and type(v) == "cdata" then -- null pointer
			return nil
		elseif baseClass.funcs[k] ~= nil then
			return setmetatable(baseClass.funcs[k], FuncMT)
		else
			baseClass = baseClass.base
		end
	end
	
	print("[Lua] Warning: Object index not found", k)

	--jit.on()

	return nil
end

function UObjectMT.__newindex(self, k, v)
	if LogObjectIndex then print("Calling UObjectMT.__newindex", self, k, v) end

	-- Get the actual class information for this object
	local classInfo = _ClassesInternal[PtrToNum(self.UObject.Class)]

	-- Check that we actually have the info for this class
	if classInfo == nil then
		print(debug.traceback())
		error(string.format("Class info not found: Name = %s, Ptr = 0x%X",
			self.UObject.Class:GetCName(),
			PtrToNum(self.UObject.Class)
		))
	end

	-- Cast this object to the right type
	local obj = ffi.cast(classInfo.ptrType, self)

	-- Since we have casted, check the actual class type first
	-- Then while this class has a base class, check that.
	local baseClass = classInfo
	while baseClass do
		if obj[baseClass.name][k] == nil and type(v) == nil then
			baseClass = baseClass.base
		else
			obj[baseClass.name][k] = v
			return
		end
	end
	
	print("[Lua] Warning: Object index not found", k)
end

local UObjectDataMT = {}

function UObjectDataMT.__index(self, k)
	return nil
end

-- Public members
engine.LogObjectIndex = LogObjectIndex
engine.UObjectMT = UObjectMT
engine.UObjectDataMT = UObjectDataMT