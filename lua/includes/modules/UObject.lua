local ffi = require("ffi")

local UObjectMT = { __index = {} }

function UObjectMT.__index.IsA(self, class)
	-- class is a table from engine.Classes
	local class_instance = class.static

	local superclass = self.UObject.Class

	while NotNull(superclass) do
		if superclass == class_instance then
			return true
		end

		superclass = ffi.cast("struct UClass*", superclass.UStruct.SuperField)
	end

	return false
end

function UObjectMT.__index.GetName(self)

	return self.UObject.Name:GetName()

end

function UObjectMT.__index.GetFullName(self)

	if NotNull(self.UObject.Class) and NotNull(self.UObject.Outer) then

		local fullname

		if NotNull(self.UObject.Outer.UObject.Outer) then
			fullname = string.format("%s %s.%s.%s", 
				self.UObject.Class:GetName(),
				self.UObject.Outer.UObject.Outer:GetName(),
				self.UObject.Outer:GetName(),
				self:GetName()
			)
		else
			fullname = string.format("%s %s.%s", 
				self.UObject.Class:GetName(),
				self.UObject.Outer:GetName(),
				self:GetName()
			)
		end

		return fullname

	end

	return "(null)"
end

-- TOOD: Fix this steaming pile of shit.
function UObjectMT.__index.GetCName(self)

	local cname
	if self:IsA(engine.Classes.UClass) then
		cname = "U" -- Just a plain old object by default

		local class = self
		while NotNull(class) do
			if class:GetName() == "Actor" then
				cname = "A"
				break
			end
		end
	else
		cname = "F"
	end

	return cname .. self:GetName()
end

function UObjectMT.__index.GetPackageObject(self)

	local pkg = nil
	local outer = self.UObject.Outer

	while NotNull(outer) do
		
		pkg = outer
		outer = outer.UObject.Outer

	end

	return pkg

end

module("UObject")

MetaTable = UObjectMT