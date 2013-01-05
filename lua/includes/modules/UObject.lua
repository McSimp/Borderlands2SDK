local ffi = require("ffi")

local UObjectMT = {}

function UObjectMT.IsA(self, class)
	-- class is a "struct UClass*"

	local superclass = self.Class

	while NotNull(superclass) do
		if superclass == class then
			return true
		end

		superclass = ffi.cast("struct UClass*", superclass.UStruct.SuperField)
	end

	return false
end

function UObjectMT.GetFullName(self)

	if NotNull(self.Class) and NotNull(self.Outer) then

		local fullname

		if NotNull(self.Outer.UObject.Outer) then

			fullname = string.format("%s %s.%s.%s", 
				self.Class.UObject.Name:GetName(),
				self.Outer.UObject.Outer.UObject.Name:GetName(),
				self.Outer.UObject.Name:GetName(),
				self.Name:GetName()
			)

		else

			fullname = string.format("%s %s.%s", 
				self.Class.UObject.Name:GetName(),
				self.Outer.UObject.Name:GetName(),
				self.Name:GetName()
			)

		end

		return fullname

	end

	return "(null)"
end

function UObjectMT.GetPackageObj(self)

	local pkg = nil
	local outer = self.Outer

	while NotNull(outer) do
		
		pkg = outer
		outer = outer.UObject.Outer

	end

	return pkg

end

ffi.metatype("struct UObject_Data", { __index = UObjectMT })

local engine = engine
local IsNull = IsNull

module("UObject")

local _sc

function StaticClass()
	if IsNull(_sc) then
		_sc = engine.FindClassSafe("Class Core.Object")
	end

	return _sc
end