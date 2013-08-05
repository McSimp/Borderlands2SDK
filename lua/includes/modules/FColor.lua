local ffi = require("ffi")
local string = string

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
