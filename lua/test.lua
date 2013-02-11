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

function MakeEnum(name, identifiers)
	local enum = {}
	for k,v in ipairs(identifiers) do
		enum[v] = (k-1)
	end

	_G[name] = enum
end

MakeEnum("Shazbot", {
	"UNATCO",
	"SAVAGE",
	"JCDENTON"
})

ffi.cdef[[
struct TestStruct {
	unsigned long hi;
};
]]

local test = ffi.new("struct TestStruct")
test.hi = 6
test.hi = Shazbot.JCDENTON

print(test.hi)