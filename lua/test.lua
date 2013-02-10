local ffi = require("ffi")

--[[
for i=0,(engine.Objects.Count-1) do

	local obj = engine.Objects:Get(i)
	if IsNull(obj) then goto continue end
	if not obj:IsA(engine.Classes.UByteProperty) then goto continue end

	obj = ffi.cast("struct UByteProperty*", obj)

	if NotNull(obj.UByteProperty.Enum) then
		print(obj:GetFullName() .. " => " .. tostring(obj.UByteProperty.Enum))
	end

	::continue::
end
]]

ffi.cdef[[
struct TArray_pUClass_ {
	int hi;
};
]]