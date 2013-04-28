local ffi = require("ffi")

ffi.cdef[[
typedef void (__thiscall *tFrameStep) (struct FFrame*, struct UObject*, void*);
]]
local pFrameStep = ffi.cast("tFrameStep", bl2sdk.addrFrameStep)

local FFrameMT = {}

function FFrameMT.ReadType(self, ptrType, size)
	local result = ffi.cast(ptrType, self.Code)[0]
	self.Code = self.Code + size
	return result
end

function FFrameMT.ReadInt(self)
	return self:ReadType(ffi.typeof("int*"), 4)
end

function FFrameMT.ReadFloat(self)
	return self:ReadType(ffi.typeof("float*"), 4)
end

function FFrameMT.ReadName(self)
	return self:ReadType(ffi.typeof("struct FName*"), ffi.sizeof("struct FName"))
end

function FFrameMT.ReadObject(self)
	return self:ReadType(ffi.typeof("struct UObject**"), 8) -- In C++, size = sizeof(ScriptPointerType) = sizeof(QWORD) = 8
end

function FFrameMT.ReadWord(self)
	return self:ReaadType(ffi.typeof("unsigned short*"), 2)
end

FFrameMT.Step = pFrameStep

local function GetGenericNumber(Stack)
	local var = ffi.new("int[1]", 0)
	pFrameStep(Stack, Stack.Object, var)
	return var[0]
end

local function GetCastedType(Stack, toCast)
	local var = ffi.new(toCast .. "[1]")
	pFrameStep(Stack, Stack.Object, var)
	return var[0]
end

FFrameMT.GetBool = GetGenericNumber
FFrameMT.GetStruct = GetCastedType
FFrameMT.GetInt = GetGenericNumber
FFrameMT.GetFloat = GetGenericNumber
FFrameMT.GetByte = GetGenericNumber

function FFrameMT.GetName(self)
	return GetCastedType(self, "struct FName")
end

function FFrameMT.GetString(self)
	return GetCastedType(self, "struct FString")
end

-- TODO: TArray inner type
function FFrameMT.GetTArray(self)
	return GetCastedType(self, "struct TArray")
end

FFrameMT.GetObject = GetCastedType -- Have to use a pointer type (like struct UObject*)

ffi.metatype("struct FFrame", { __index = FFrameMT })
