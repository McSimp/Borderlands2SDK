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
local FString = FString
local pcall = pcall
local flags = flags
local table = table
local unpack = unpack

local FUNCPARM_CLASS = 1
local FUNCPARM_NAME = 2
local FUNCPARM_STRING = 4
local FUNCPARM_TARRAY = 8
local FUNCPARM_OBJPOINTER = 16
local FUNCPARM_LUATYPE = 32
local FUNCPARM_STRUCT = 64

module("engine")

local OBJECT_HASH_BINS = 32*1024
local NAME_HASH_BINS = 65536

Objects = TArray.Create("struct UObject*", ffi.cast("struct TArray*", bl2sdk.addrGObjects))
Names = TArray.Create("struct FNameEntry*", ffi.cast("struct TArray*", bl2sdk.addrGNames))
ObjHash = ffi.cast("struct UObject**", bl2sdk.addrGObjHash)
CRCTable = ffi.cast("unsigned int*", bl2sdk.addrGCRCTable)
NameHash = ffi.cast("struct FNameEntry**", bl2sdk.addrNameHash)

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

function Strihash(str)
	str = string.upper(str)
	local hash = 0

	for i=1,string.len(str) do
		local cc = string.byte(str, i)
		-- hash = ((hash >> 8) & 0x00FFFFFF) ^ CRCTable[(hash ^ cc) & 0x000000FF]
		hash = bit.bxor(bit.band(bit.rshift(hash, 8), 0x00FFFFFF), CRCTable[bit.band(bit.bxor(hash, cc), 0x000000FF)])
		-- hash = bit.bxor(bit.rshift(hash, 8), CRCTable[bit.band(bit.bxor(hash, cc), 0x000000FF)])
	end

	return hash
end

local FuncMT = {}
local UObjectDataMT = {}
local UObjectMT = {}

local NO_MEMBER = 1471815114
function UObjectDataMT.__index()
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
	--local n = select("#", ...)

	local paramBlock = ffi.new("char[?]", funcData.dataSize)
	local pParamBlockBase = ffi.cast("char*", paramBlock)

	-- Process function arguments
	for k,v in ipairs(funcData.args) do
		local luaArg = args[k]

		if not v.optional then
			-- If the arg is nil and not a pointer type (where nil == NULL)
			if luaArg == nil and not flags.IsSet(v.flags, FUNCPARM_OBJPOINTER) then
				error(string.format("Arg #%d (%s) is required", k, v.name))
			end
		end

		-- If the luaArg is nil here, it's either a null pointer or an unspecified optional arg.
		-- We can safely skip it
		if luaArg == nil then
			goto continue
		end

		-- If arg expects a lua type, and it's not the right lua type
		if flags.IsSet(v.flags, FUNCPARM_LUATYPE) and type(luaArg) ~= v.type then
			error(string.format("Arg #%d (%s) expects the Lua type %q", k, v.name, v.type))
		end

		-- If we're expecting a class, it should be a UClass* or an engine.Classes.name table with a static member
		if flags.IsSet(v.flags, FUNCPARM_CLASS) then
			if type(luaArg) == "table" then
				if luaArg.static ~= nil then
					luaArg = luaArg.static
				else
					error(string.format("Arg #%d (%s) did not contain a valid class table", k, v.name))
				end
			elseif not ffi.istype(v.type, luaArg) then
				error(string.format("Arg #%d (%s) expects a class", k, v.name))
			end
		end

		-- If we're expecting a name and we get a string, we need to convert it to an FName
		-- If it's not a string, it should be a struct FName
		if flags.IsSet(v.flags, FUNCPARM_NAME) then
			if type(luaArg) == "string" then
				local name = FindName(luaArg)
				if name == nil then
					error(string.format("Arg #%d (%s): Name for %q not found", k, v.name, luaArg))
				end
				luaArg = name
			elseif not ffi.istype(v.type, luaArg) then
				error(string.format("Arg #%d (%s) expects a name", k, v.name))
			end
		end

		-- If we're expecting an FString, and we get a normal string, convert it to an FString
		-- Otherwise make sure it's a struct FString
		if flags.IsSet(v.flags, FUNCPARM_STRING) then
			if type(luaArg) == "string" then
				luaArg = FString.GetFromLuaString(luaArg)
			elseif not ffi.istype(v.type, luaArg) then
				error(string.format("Arg #%d (%s) expects a string", k, v.name))
			end
		end

		-- If it's a TArray, accept a table or an actual struct TArray
		if flags.IsSet(v.flags, FUNCPARM_TARRAY) then
			if type(luaArg) == "table" then
				-- TODO: Convert table, set luaArg to struct
				error("NYI: Converting lua table to TArray")
			elseif not ffi.istype(v.type, luaArg) then
				error(string.format("Arg #%d (%s) expects a %q", k, v.name, v.type))
			end
		end

		if flags.IsSet(v.flags, FUNCPARM_STRUCT) and not ffi.istype(v.type, luaArg) then
			error(string.format("Arg #%d (%s) expects a %q", k, v.name, tostring(v.type)))
		end

		if flags.IsSet(v.flags, FUNCPARM_OBJPOINTER) and (luaArg.IsA == nil or not luaArg:IsA(v.class)) then
			error(string.format("Arg #%d (%s) expects an object pointer for %s", k, v.name, v.class.name))
		end

		-- Finally set the actual field
		local field = ffi.cast(v.castTo, pParamBlockBase + v.offset)
		field[0] = luaArg

		::continue::
	end

	local parms = ""
	for i=0,(funcData.dataSize-1) do
		parms = parms .. string.format("%s ", bit.tohex(paramBlock[i], 2))
	end
	print(parms)

	-- Have we got a pointer?
	if not funcData.ptr or funcData.ptr == nil then
		error("Function does not have a valid pointer")
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

function FuncMT.__call(funcData, obj, ...)
	return CallFunc(funcData, obj, ...)
end

LogObjectIndex = false

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
		if v ~= NO_MEMBER then
			if v == nil then -- If the return value is a null pointer, return nil
				return nil
			else
				return v
			end
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
		if obj[baseClass.name][k] ~= NO_MEMBER then
			obj[baseClass.name][k] = v
			return
		else
			baseClass = baseClass.base
		end
	end
	
	print("[Lua] Warning: Object index not found", k)
end

function FindName(str)
	str = string.upper(str)
	local iHash = bit.band(Strihash(str), 65535)

	local hash = NameHash[iHash]
	while hash ~= nil do
		if string.upper(ffi.string(hash.Name)) == str then
			return ffi.new("struct FName", bit.rshift(hash.Index, 1), 0)
		end

		hash = hash.HashNext
	end

	return nil
end

local localPC = nil
function LocalPlayer()
	if localPC == nil then
		localPC = FindObjectExactClass("WillowPlayerController TheWorld.PersistentLevel.WillowPlayerController", Classes.AWillowPlayerController)
	end

	return localPC
end

function MakeEnum(name, identifiers)
	local enum = {}
	for i=1,#identifiers do
		enum[identifiers[i]] = (i-1)
	end

	enums[name] = enum
end

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

local function ResolveArgClasses()
	for _,funcData in pairs(_FuncsInternal) do
		for _,arg in ipairs(funcData.args) do
			if arg.className ~= nil then
				arg.class = Classes[arg.className]
				arg.className = nil
			end
		end
	end
end

function Initialize()
	profiling.StartTimer("engineinit", "Engine Initialization")

	print("[Lua] Initializing engine classes...")

	-- Initialize metatables on all classes
	InitializeClasses()

	-- Add the TArray metatable to all the template types
	InitializeTArrays()

	-- Resolve the classes in the function arguments
	ResolveArgClasses()

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