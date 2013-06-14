local ffi = require("ffi")
local bit = require("bit")
local ipairs = ipairs
local error = error
local string = string
local flags = flags
local type = type
local FString = FString
local print = print
local tostring = tostring
local table = table
local unpack = unpack

local FindName = engine.FindName

FUNCPARM_CLASS = 1
FUNCPARM_NAME = 2
FUNCPARM_STRING = 4
FUNCPARM_TARRAY = 8
FUNCPARM_OBJPOINTER = 16
FUNCPARM_LUATYPE = 32
FUNCPARM_STRUCT = 64

-- ProcessEvent - basically lets us call any engine function
ffi.cdef[[
typedef void (__thiscall *tProcessEvent) (struct UObject*, struct UFunction*, void*, void*);
]]
local pProcessEvent = ffi.cast("tProcessEvent", bl2sdk.addrProcessEvent)

local FuncMT = {}

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

function FuncMT.__call(funcData, obj, ...)
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

-- Public members
engine.FuncMT = FuncMT