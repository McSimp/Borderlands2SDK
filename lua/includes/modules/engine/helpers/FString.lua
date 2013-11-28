local ffi = require("ffi")
local string = string

ffi.cdef[[
size_t wcstombs(char* dest, const wchar_t* src, size_t max);
size_t mbstowcs(wchar_t* dest, const char* src, size_t max);
int _wcsnicmp(const wchar_t* wcs1, const wchar_t* wcs2, size_t num);
]]

local FStringMT = { __index = {} }

function FStringMT.__index:GetLuaString()
	local buff = ffi.new("char[?]", self.Count)
	local size = ffi.C.wcstombs(buff, self.Data, self.Count)
	return ffi.string(buff, size)
end

function FStringMT.__index:IsValid()
	return self.Data ~= nil
end

FStringMT.__tostring = FStringMT.__index.GetLuaString

function FStringMT.__eq(self, cmp)
	if ffi.istype("struct FString", cmp) then
		if self.Data ~= nil and cmp.Data ~= nil then
			return ffi.C._wcsnicmp(self.Data, cmp.Data, self.Count) == 0
		end
	end

	return rawequal(self, cmp)
end

ffi.metatype("struct FString", FStringMT)

local FString = {}

function FString.GetFromLuaString(str)
	-- TODO: What about GC?
	local len = string.len(str) + 1
	local buff = ffi.new("wchar_t[?]", len)
	ffi.C.mbstowcs(buff, str, len)
	return ffi.new("struct FString", buff, len, len)
end

return FString
