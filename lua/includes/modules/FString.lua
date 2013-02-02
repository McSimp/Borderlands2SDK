local ffi = require("ffi")

ffi.cdef[[
size_t wcstombs(char* dest, const wchar_t* src, size_t max);
]]

local FStringMT = {}

function FStringMT:GetLuaString()
	local buff = ffi.new("char[?]", self.Count)
	local size = ffi.C.wcstombs(buff, self.Data, self.Count)
	return ffi.string(buff, size)
end

ffi.metatype("struct FString", { __index = FStringMT })