local ffi = require("ffi")

local funcs = {}

function funcs.IsA(self, class)
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

function funcs.GetName(self)

	return self.UObject.Name:GetName()

end

ffi.cdef[[
	char* LUAFUNC_UObjectGetFullName(struct UObject* obj);
]]

function funcs.GetFullName(self)
	return ffi.string(ffi.C.LUAFUNC_UObjectGetFullName(self))
end

-- TOOD: Fix this steaming pile of shit.
function funcs.GetCName(self)

	local cname
	if self:IsA(engine.Classes.UClass) then
		cname = "U" -- Just a plain old object by default

		local class = ffi.cast("struct UClass*", self)
		while NotNull(class) do
			if class:GetName() == "Actor" then
				cname = "A"
				break
			end
			class = ffi.cast("struct UClass*", class.UStruct.SuperField)
		end
	else
		cname = "F"
	end

	return cname .. self:GetName()
end

function funcs.GetPackageObject(self)

	local pkg = nil
	local outer = self.UObject.Outer

	while NotNull(outer) do
		
		pkg = outer
		outer = outer.UObject.Outer

	end

	return pkg

end

module("UObject")

BaseFuncs = funcs