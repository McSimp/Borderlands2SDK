--require("jit.v")

--jit.v.on("test.txt")

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