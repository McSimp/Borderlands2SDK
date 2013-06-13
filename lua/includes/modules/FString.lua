local ffi = require("ffi")
local string = string

ffi.cdef[[
size_t wcstombs(char* dest, const wchar_t* src, size_t max);
size_t mbstowcs(wchar_t* dest, const char* src, size_t max);
]]

local FStringMT = {}

function FStringMT:GetLuaString()
	local buff = ffi.new("char[?]", self.Count)
	local size = ffi.C.wcstombs(buff, self.Data, self.Count)
	return ffi.string(buff, size)
end

ffi.metatype("struct FString", { __index = FStringMT })

module("FString")

function GetFromLuaString(str)
	-- TODO: What about GC?
	local buff = ffi.new("wchar_t[?]", string.len(str))
	local size = ffi.C.mbstowcs(buff, str, string.len(str))
	local struct = ffi.new("struct FString", buff, size, size)
	return struct
end