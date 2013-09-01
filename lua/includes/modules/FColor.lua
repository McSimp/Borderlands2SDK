local ffi = require("ffi")
local string = string
local math = math
local tonumber = tonumber

local FColorMT = { __index = {} }

function FColorMT.__eq(self, cmp)
	if not ffi.istype("struct FColor", cmp) then
		return rawequal(self, cmp)
	else
		return 
			cmp.R == self.R and
			cmp.G == self.G and
			cmp.B == self.B and
			cmp.A == self.A
	end
end

function FColorMT.__tostring(self)
	return string.format("FColor: R=%d, G=%d, B=%d, A=%d", self.R, self.G, self.B, self.A)
end

ffi.metatype("struct FColor", FColorMT)

function Color(r, g, b, a)
	if a == nil then a = 255 end
	local col = ffi.new("struct FColor")

	col.B = math.clamp(tonumber(b), 0, 255)
	col.G = math.clamp(tonumber(g), 0, 255)
	col.R = math.clamp(tonumber(r), 0, 255)
	col.A = math.clamp(tonumber(a), 0, 255)

	return col
end
