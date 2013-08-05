local ffi = require("ffi")
ffi.cdef[[
struct UPackage* LUAFUNC_LoadPackage(struct UPackage* outer, const wchar_t* filename, unsigned long flags)
]]

function TestLoad(name)
	local len = string.len(name) + 1
	local buff = ffi.new("wchar_t[?]", len)
	ffi.C.mbstowcs(buff, name, len)

	local ret = ffi.C.LUAFUNC_LoadPackage(nil, buff, 0)
	print(ret)
end
