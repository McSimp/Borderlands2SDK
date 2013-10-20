local ffi = require("ffi")

local FNameMT = { __index = {} }

function FNameMT.__index.GetName(self)
	return ffi.string(engine.Names[self.Index].Name)
end

function FNameMT.__eq(self, cmp)
	if type(cmp) ~= "string" then 
		return rawequal(self, cmp)
	else
		return (self:GetName() == cmp)
	end
end

function FNameMT.__tostring(self)
	return self:GetName()
end

ffi.metatype("struct FName", FNameMT)

