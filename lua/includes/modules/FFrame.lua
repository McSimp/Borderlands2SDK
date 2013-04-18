local ffi = require("ffi")

local FFrameMT = {}
local NativeFunctions = {}



function FFrameMT.ReadInt(self)
	local result = ffi.cast("int*", self.Code)[0]
	self.Code = self.Code + 4
	return result
end

function FFrameMT.ReadFloat(self)
	local result = ffi.cast("float*", self.Code)[0]
	self.Code = self.Code + 4
	return result
end

function FFrameMT.ReadName(self)
	local result = ffi.cast("struct FName*", self.Code)[0]
	self.Code = self.Code + ffi.sizeof("struct FName")
	return result
end

function FFrameMT.ReadObject(self)
	local result = ffi.cast("struct UObject*", self.Code)[0]
	self.Code = self.Code + ffi.sizeof("unsigned long long")
	return result
end

function FFrameMT.ReadWord(self)
	local result = ffi.cast("unsigned short*", self.Code)[0]
	self.Code = self.Code + 2
	return result
end


ffi.metatype("struct FFrame", { __index = FFrameMT })