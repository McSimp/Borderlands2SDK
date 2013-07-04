local ffi = require("ffi")

local FNameMT = { __index = {} }

function FNameMT.__index.GetName(self)
	return ffi.string(engine.Names:Get(self.Index).Name)
end

function FNameMT.__eq(self, cmp)
	if type(cmp) ~= "string" then 
		return rawequal(self, cmp)
	else
		return (self:GetName() == cmp)
	end
end

ffi.metatype("struct FName", FNameMT)

