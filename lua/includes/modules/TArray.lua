local ffi = require("ffi")

ffi.cdef[[
	struct TArray {
		unsigned char* Data;
		int Count;
		int Max;
	};
]]

local TArrayMT = {}

function TArrayMT.Get(self, idx)
	if idx < self.Count and idx >= 0 then
		return self.Data[idx]
	else
		print("[TArray] Warning: Index out of range")
		return nil
	end
end

ffi.metatype("struct TArray", { __index = TArrayMT })

function TArray(innerType, cdata)

	local type = ffi.typeof([[
	struct {
		$* Data;
		int Count;
		int Max;
	}]], ffi.typeof(innerType))
	local type_mt = ffi.metatype(type, { __index = TArrayMT })
	local type_ptr = ffi.typeof("$ *", type_mt)

	local data = ffi.cast(type_ptr, cdata)

	local mt = {
		__index = data,
		__newindex = function(self, k, v)
			error("Cannot set property '" .. k .. "' on TArray")
		end
	}

	return setmetatable({}, mt)
end