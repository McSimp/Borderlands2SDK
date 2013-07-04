local ffi = require("ffi")
local string = string

ffi.cdef[[
size_t wcstombs(char* dest, const wchar_t* src, size_t max);
size_t mbstowcs(wchar_t* dest, const char* src, size_t max);
int wcsncmp(const wchar_t* wcs1, const wchar_t* wcs2, size_t num);
]]

local FStringMT = { __index = {} }

function FStringMT.__index:GetLuaString()
	local buff = ffi.new("char[?]", self.Count)
	local size = ffi.C.wcstombs(buff, self.Data, self.Count)
	return ffi.string(buff, size)
end

function FStringMT.__index:IsValid()
	return (self.Data ~= nil)
end

FStringMT.__tostring = FStringMT.__index.GetLuaString

function FStringMT.__eq(self, cmp)
	if ffi.istype("struct FString", cmp) then
		if self.Data ~= nil and cmp.Data ~= nil then
			return (ffi.C.wcsncmp(self.Data, cmp.Data, self.Count) == 0)
		end
	end

	return rawequal(self, cmp)
end

ffi.metatype("struct FString", FStringMT)

module("FString")

function GetFromLuaString(str)
	-- TODO: What about GC?
	local buff = ffi.new("wchar_t[?]", string.len(str))
	local size = ffi.C.mbstowcs(buff, str, string.len(str))
	local struct = ffi.new("struct FString", buff, size, size)
	return struct
end