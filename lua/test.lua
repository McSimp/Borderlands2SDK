--require("jit.v")

--jit.v.on("test.txt")
--[[
local start = os.clock()
local sum = 0
local skipped = 0
for i=0,(engine.Objects.Count-1) do 
	local obj = engine.Objects:Get(i)
	if NotNull(obj) then
		sum = sum + string.len(obj.UObject.Name:GetName())
		--sum = sum + 1
	else
		skipped = skipped + 1
	end
end
print(skipped)
print(sum)
print(string.format("elapsed time: %.3f\n", os.clock() - start))

local start = os.clock()
local sum = 0
local skipped = 0
for i=0,(engine.Objects.Count-1) do 
	local obj = engine.Objects:Get(i)
	if NotNull(obj) then
		sum = sum + string.len(obj:GetName())
		--sum = sum + 1
	else
		skipped = skipped + 1
	end
end
print(skipped)
print(sum)
print(string.format("elapsed time: %.3f\n", os.clock() - start))
]]
--[[
local classclass = engine.FindClassSafe("Class Core.Class")
local classes = 0

for i=0,(engine.Objects.Count-1) do
	local obj = engine.Objects:Get(i)
	if IsNull(obj) then goto continue end

	if obj.UObject:IsA(classclass) then
		classes = classes + 1
		--print(obj.UObject:GetFullName())
	end

	::continue::
end

print(classes)
]]
local ffi = require("ffi")
--[[
local innerProps = {}
local totalArrays = 0

for i=0,(engine.Objects.Count-1) do 
	local obj = engine.Objects:Get(i)
	if NotNull(obj) then
		if obj.UObject.Class:GetName() == "ArrayProperty" then
			totalArrays = totalArrays + 1
			obj = ffi.cast("struct UArrayProperty*", obj)
			print(obj)
			print(obj.UArrayProperty.Inner)
			if IsNull(obj.UArrayProperty.Inner) then break end
			--print(obj.UArrayProperty.Inner.UObject.Class:GetName())
			--if not table.contains(innerProps, obj.UArrayProperty.Inner) then
			--	table.insert(innerProps, obj.UArrayProperty.Inner)
			--end
		end
	end
end


print(#innerProps)
print(totalArrays)
]]


--local testpoint = setmetatable({ CData = engine.Objects:Get(10) }, PointerMT)
local testpoint = setmetatable({ CData = ffi.cast("struct UArrayProperty*", 0x04149918) }, PointerMT)

--print(engine.Objects:Get(10):GetFullName())
print(testpoint.UObject.Class)
print(testpoint.UArrayProperty.Inner:GetName())