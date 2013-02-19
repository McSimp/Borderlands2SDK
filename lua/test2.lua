local ffi = require("ffi")

g_loadedClasses["UObject"][3] = {
	["Trace"] = {
		args = {
			{ name = "TraceEnd", cdata = true,
				type = ffi.typeof("struct FVector"),
				castTo = ffi.typeof("struct FVector*"),
				offset = 24
			},
			{
				name = "TraceStart",
				optional = true,
				cdata = true,
				type = ffi.typeof("struct FVector"),
				castTo = ffi.typeof("struct FVector*"),
				offset = 36
			},
			{
				name = "bTraceActors",
				optional = true,
				type = "boolean",
				castTo = ffi.typeof("unsigned long*"),
				offset = 48,
			},
			{
				name = "Extent",
				optional = true,
				cdata = true,
				type = ffi.typeof("struct FVector"),
				castTo = ffi.typeof("struct FVector*"),
				offset = 52,
			},
			{
				name = "ExtraTraceFlags",
				optional = true,
				type = "number",
				castTo = ffi.typeof("int*"),
				offset = 92,
			},
			{
				name = "bTraceBulletListeners",
				optional = true,
				type = "boolean",
				castTo = ffi.typeof("unsigned long*"),
				offset = 96,
			},
			{
				name = "BulletListenerSource",
				optional = true,
				cdata = true,
				type = ffi.typeof("struct AActor*"),
				castTo = ffi.typeof("struct AActor**"),
				offset = 100,
			}
		},
		retVals = {
			{
				name = "ReturnValue",
				type = ffi.typeof("struct AActor*"),
				castTo = ffi.typeof("struct AActor**"),
				offset = 104
			},
			{
				name = "HitLocation",
				type = ffi.typeof("struct FVector"),
				castTo = ffi.typeof("struct FVector*"),
				offset = 0
			},
			{
				name = "HitNormal",
				type = ffi.typeof("struct FVector"),
				castTo = ffi.typeof("struct FVector*"),
				offset = 12
			},
			{
				name = "HitInfo",
				type = ffi.typeof("struct FTraceHitInfo"),
				castTo = ffi.typeof("struct FTraceHitInfo*"),
				offset = 64
			}
		},
		dataSize = 108,
		ptr = ffi.cast("struct UFunction*", engine.Objects:Get(7273))
	}
}

local funcData = {
	name = "Trace",
	args = {
		{ name = "TraceEnd", cdata = true,
			type = ffi.typeof("struct FVector"),
			castTo = ffi.typeof("struct FVector*"),
			offset = 24
		},
		{
			name = "TraceStart",
			optional = true,
			cdata = true,
			type = ffi.typeof("struct FVector"),
			castTo = ffi.typeof("struct FVector*"),
			offset = 36
		},
		{
			name = "bTraceActors",
			optional = true,
			type = "boolean",
			castTo = ffi.typeof("unsigned long*"),
			offset = 48,
		},
		{
			name = "Extent",
			optional = true,
			cdata = true,
			type = ffi.typeof("struct FVector"),
			castTo = ffi.typeof("struct FVector*"),
			offset = 52,
		},
		{
			name = "ExtraTraceFlags",
			optional = true,
			type = "number",
			castTo = ffi.typeof("int*"),
			offset = 92,
		},
		{
			name = "bTraceBulletListeners",
			optional = true,
			type = "boolean",
			castTo = ffi.typeof("unsigned long*"),
			offset = 96,
		},
		{
			name = "BulletListenerSource",
			optional = true,
			cdata = true,
			type = ffi.typeof("struct AActor*"),
			castTo = ffi.typeof("struct AActor**"),
			offset = 100,
		}
	},
	retVals = {
		{
			name = "ReturnValue",
			type = ffi.typeof("struct AActor*"),
			castTo = ffi.typeof("struct AActor**"),
			offset = 104
		},
		{
			name = "HitLocation",
			type = ffi.typeof("struct FVector"),
			castTo = ffi.typeof("struct FVector*"),
			offset = 0
		},
		{
			name = "HitNormal",
			type = ffi.typeof("struct FVector"),
			castTo = ffi.typeof("struct FVector*"),
			offset = 12
		},
		{
			name = "HitInfo",
			type = ffi.typeof("struct FTraceHitInfo"),
			castTo = ffi.typeof("struct FTraceHitInfo*"),
			offset = 64
		}
	},
	dataSize = 108,
	ptr = ffi.cast("struct UFunction*", engine.Objects:Get(7273))
}

local funcData2 = {
	name = "GetAxes",
	args = {
		{ 
			name = "A",
			cdata = true,
			type = ffi.typeof("struct FRotator"),
			castTo = ffi.typeof("struct FRotator*"),
			offset = 0
		}
	},
	retVals = {
		{
			name = "X",
			cType = ffi.typeof("struct FVector"),
			castTo = ffi.typeof("struct FVector*"),
			offset = 12
		},
		{
			name = "XdotX",
			castTo = ffi.typeof("float*"),
			offset = 12
		},
		{
			name = "Y",
			cType = ffi.typeof("struct FVector"),
			castTo = ffi.typeof("struct FVector*"),
			offset = 24
		},
		{
			name = "Z",
			cType = ffi.typeof("struct FVector"),
			castTo = ffi.typeof("struct FVector*"),
			offset = 36
		}
	},
	dataSize = 48,
	ptr = ffi.cast("struct UFunction*", engine.Objects:Get(6140))
}

ffi.cdef[[
typedef void (__thiscall *tProcessEvent) (struct UObject*, struct UFunction*, void*, void*);
]]
local pProcessEvent = ffi.cast("tProcessEvent", 0x65C820)

function GetReturn(retVal, pParamBlockBase)
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

	-- Call func
	local func = funcData.ptr
	func.UFunction.FunctionFlags = bit.bor(func.UFunction.FunctionFlags, bit.bnot(0x400))
	
	local native = func.UFunction.iNative
	func.UFunction.iNative = 0

	pProcessEvent(obj, func, paramBlock, nil)

	func.UFunction.iNative = native

	-- This is a fairly common occurrence, usually just a bool, so we can just handle
	-- this without having to fallback to the interpreter with unpack()
	if #funcData.retVals == 0 then
		return
	elseif #funcData.retVals == 1 then
		return GetReturn(funcData.retVals[1], pParamBlockBase)
	else
		local returns = {}
		for _,v in ipairs(funcData.retVals) do
			table.insert(returns, GetReturn(v, pParamBlockBase))
		end

		return unpack(returns)
	end
end

--[[
local pc = engine.FindObject("WillowPlayerController TheWorld.PersistentLevel.WillowPlayerController", engine.Classes.AWillowPlayerController)
print(pc)
local X, XdotX, Y,Z = CallFunc(funcData2, pc, pc)
print(X.X, X.Y, X.Z)
print(XdotX)
print(Y.X, Y.Y, Y.Z)
print(Z.X, Z.Y, Z.Z)
]]
--print(CallFunc(funcData, pc, )))
