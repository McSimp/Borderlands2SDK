local ffi = require("ffi")

ffi.cdef[[
	struct UObject_Data { 
		unsigned char Unknown[0x28];
		struct UObject* Outer;
		struct FName Name;
		struct UClass* Class;
		struct UObject* ObjectArchetype;
	};

	struct UObject {
		struct UObject_Data UObject;
	};
]]

local UObjectMT = {}

function UObjectMT.IsA(self, class)
	-- class is a "struct UClass*"

	local superclass = self.UObject.Class

	while NotNull(superclass) do
		if superclass == class then
			return true
		end

		superclass = ffi.cast("struct UClass*", superclass.UStruct.SuperField)
	end

	return false
end

function UObjectMT.GetFullName(self)
	print(self)
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

		print(fullname)

		return fullname

	end

	return "(null)"
end

function UObjectMT.GetPackageObj(self)

	local pkg = nil
	local outer = self.UObject.Outer

	while NotNull(outer) do
		
		pkg = outer
		outer = outer.UObject.Outer

	end

	return pkg

end

ffi.metatype("struct UObject_Data", { __index = UObjectMT })

module("UObject")

StaticClass = nil