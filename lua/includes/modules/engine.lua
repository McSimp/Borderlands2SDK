local ffi = require("ffi")
local bit = require("bit")

local TArray = TArray
local IsNull = IsNull
local error = error
local g_loadedClasses = g_loadedClasses
local g_classFuncs = g_classFuncs
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
local setmetatable = setmetatable
local ipairs = ipairs
local pairs = pairs
local jit = jit
local bl2sdk = bl2sdk

module("engine")

local OBJECT_HASH_BINS = 32*1024

Objects = TArray.Create("struct UObject*", ffi.cast("struct TArray*", bl2sdk.addrGObjects))
Names = TArray.Create("struct FNameEntry*", ffi.cast("struct TArray*", bl2sdk.addrGNames))
ObjHash = ffi.cast("struct UObject**", bl2sdk.addrGObjHash)

ffi.cdef[[
typedef void (__thiscall *tProcessEvent) (struct UObject*, struct UFunction*, void*, void*);
]]
local pProcessEvent = ffi.cast("tProcessEvent", bl2sdk.addrProcessEvent)

_ClassesInternal = {}
Classes = {}
_FuncsInternal = {}
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

function FindObjectExactClass(objectName, class)
	for i=0,(Objects.Count-1) do
		local obj = Objects:Get(i)
		if IsNull(obj) then goto continue end
		if obj.UObject.Class ~= class.static then goto continue end

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

local NO_MEMBER = 1471815114
local function NilIndex()
	--return nil
	return NO_MEMBER
end

local function GetReturn(retVal, pParamBlockBase)
	local field = ffi.cast(retVal.castTo, pParamBlockBase + retVal.offset)

	if not retVal.cType then
		return field[0]
	else
		local new = ffi.new(retVal.cType)
		ffi.copy(new, field, ffi.sizeof(retVal.cType))

		return new
	end
end

function CallFunc(funcData, obj, ...)
	local args = { ... }

	local paramBlock = ffi.new("char[?]", funcData.dataSize)
	local pParamBlockBase = ffi.cast("char*", paramBlock)

	for k,v in ipairs(funcData.args) do
		local luaArg = args[k]

		if not v.optional then
			if luaArg == nil then
				error(string.format("Arg #%d (%s) is required", k, v.name))
			elseif not v.cdata and type(luaArg) ~= v.type then
				error(string.format("Arg #%d (%s) expects a Lua %s", k, v.name, v.type))
			elseif v.cdata and not ffi.istype(v.type, luaArg) then
				error(string.format("Arg #%d (%s) expects a cdata %s", k, v.name, v.type))
			end
		end

		if luaArg ~= nil then
			local field = ffi.cast(v.castTo, pParamBlockBase + v.offset)
			field[0] = luaArg
		end
	end

	--for i=0,(funcData.dataSize-1) do
	--	io.write(string.format("%d ", paramBlock[i]))
	--end

	-- Have we got a pointer?
	if not funcData.ptr or funcData.ptr == nil then
		error("Function does not have a valid pointer")
		--funcData.ptr = ffi.cast("struct UFunction*", Objects:Get(funcData.index))
		--funcData.index = nil
	end

	-- Call func
	local func = funcData.ptr
	-- TODO: This is not the right approach, do some RE of ProcessEvent in the engine
	func.UFunction.FunctionFlags = bit.bor(func.UFunction.FunctionFlags, bit.bnot(0x400))
	
	local native = func.UFunction.iNative
	func.UFunction.iNative = 0

	pProcessEvent(ffi.cast("struct UObject*", obj), func, paramBlock, nil)

	func.UFunction.iNative = native

	-- This is a fairly common occurrence, usually just a bool, so we can just handle
	-- this without having to fallback to the interpreter with unpack()
	if #funcData.retvals == 0 then
		return
	elseif #funcData.retvals == 1 then
		return GetReturn(funcData.retvals[1], pParamBlockBase)
	else
		local returns = {}
		for _,v in ipairs(funcData.retvals) do
			table.insert(returns, GetReturn(v, pParamBlockBase))
		end

		return unpack(returns)
	end
end

local FuncMT = { __call = CallFunc }

LogObjectIndex = false

local function UObjectIndex(self, k)
	-- First check the base functions
	if BaseObjFuncs[k] ~= nil then return BaseObjFuncs[k] end

	if LogObjectIndex then print("Calling object index", self, k) end

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
	local casted = ffi.cast(classInfo.ptrType, self)

	-- Unfortunately, LuaJIT seems to have a problem with 
	-- casted[base["name"]][k], so I have to turn JIT compilation off.
	-- TODO: Figure out what exactly the problem is, maybe create a bug report.
	jit.off()

	-- Since we have casted, check the actual class type first
	-- Then while this class has a base class, check that.
	local base = classInfo
	while base do
		if casted[base["name"]][k] ~= NO_MEMBER then
			return casted[base["name"]][k]
		elseif base["funcs"][k] ~= nil then
			return setmetatable(base["funcs"][k], FuncMT)
		else
			base = base["base"]
		end
	end
	
	print("[Lua] Warning: Object index not found", k)

	jit.on()

	return nil
end

function MakeEnum(name, identifiers)
	local enum = {}
	for i=1,#identifiers do
		enum[identifiers[i]] = (i-1)
	end

	enums[name] = enum
end

local UObjectDataMT = { __index = NilIndex }
local UObjectMT = { __index = UObjectIndex }

local function InitializeFunctions(funcsTable)
	if funcsTable == nil then return 0 end

	-- Foreach function, get its pointer and add it to the _FuncsInternal map
	local count = 0
	for _,funcData in pairs(funcsTable) do -- NOOO NOT PAIRS
		funcData.ptr = ffi.cast("struct UFunction*", Objects:Get(funcData.index))
		funcData.index = nil
		_FuncsInternal[PtrToNum(funcData.ptr)] = funcData
		count = count + 1
	end

	return count
end

local function InitializeClasses()
	for i=1,#g_loadedClasses do
		ffi.metatype("struct " .. g_loadedClasses[i][1], UObjectMT) -- Everything is a UObject, so set its MT on everything
		ffi.metatype("struct " .. g_loadedClasses[i][1] .. "_Data", UObjectDataMT) -- Makes the _Data types return nil
	end

	local funcCount = 0

	for i=1,#g_loadedClasses do
		local class = g_loadedClasses[i] -- 1 = name, 2 = Full Name, 3 = Base name

		local members = {
			name = class[1],
			base = Classes[class[3]],
			ptrType = ffi.typeof("struct " .. class[1] .. "*"),
			funcs = g_classFuncs[class[1]]
		}

		-- If it's a string, it's a full name and we need to search.
		if type(class[2]) == "string" then
			members.static = FindClassSafe(class[2])
		else -- Otherwise it's just an offset and we can just get it out of the array
			members.static = Objects:Get(class[2])
			if IsNull(members.static) then
				error("Failed to find class '" .. class[1]  .. "'")
			end
		end

		_ClassesInternal[PtrToNum(members.static)] = members
		Classes[class[1]] = members

		funcCount = funcCount + InitializeFunctions(members.funcs)
	end

	print(string.format("[Lua] %d classes initialized", #g_loadedClasses))
	print(string.format("[Lua] %d functions initialized", funcCount))

	g_loadedClasses = nil
	g_classFuncs = nil
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

ffi.cdef[[
void LUAFUNC_LogAllProcessEventCalls(bool enabled);
void LUAFUNC_LogAllUnrealScriptCalls(bool enabled);
]]

function LogAllProcessEventCalls(enabled)
	ffi.C.LUAFUNC_LogAllProcessEventCalls(enabled)
end

function LogAllUnrealScriptCalls(enabled)
	ffi.C.LUAFUNC_LogAllUnrealScriptCalls(enabled)
end