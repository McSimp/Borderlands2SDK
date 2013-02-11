local ffi = require("ffi")
local setmetatable = setmetatable
local error = error

local TArrayMT = { __index = {} }

function TArrayMT.__index.Get(self, idx)
	if idx < self.Count and idx >= 0 then
		return self.Data[idx]
	else
		print("[TArray] Warning: Index out of range")
		return nil
	end
end

-- Using pairs is probably slower than a normal for loop, but it's a tad more convenient
local function TArrayIter(obj, k)

	if k < (obj.Count - 1) then -- If current index is before the last index
		k = k + 1

		local v = obj.Data[k]
		if NotNull(v) then
			return k, v
		else
			return TArrayIter(obj, k)
		end
	end

end

function TArrayMT.__pairs(self)
	return TArrayIter, self, -1 -- neg 1 because TArrayIter will increment this to 0
end

function TArrayMT.__ipairs(self)
	return TArrayIter, self, -1 -- neg 1 because TArrayIter will increment this to 0
end

ffi.metatype("struct TArray", TArrayMT)

module("TArray")

function Create(innerType, cdata)

	local type = ffi.typeof([[
	struct {
		$* Data;
		int Count;
		int Max;
	}]], ffi.typeof(innerType))
	local type_mt = ffi.metatype(type, TArrayMT)
	local type_ptr = ffi.typeof("$ *", type_mt)

	local data = ffi.cast(type_ptr, cdata)

	local mt = {
		__index = data,
		__newindex = function(self, k, v)
			error("Cannot set property '" .. k .. "' on TArray")
		end,
		--__pairs = TArrayMT.__pairs,
	}

	return setmetatable({}, mt)
end

BaseMT = TArrayMT