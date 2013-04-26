local ffi = require("ffi")

ffi.cdef[[
typedef void (__thiscall *tFrameStep) (struct FFrame*, struct UObject*, void* const);
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

ffi.metatype("struct FFrame", { __index = FFrameMT })