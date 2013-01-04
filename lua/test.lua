local start = os.clock()
local sum = 0
local skipped = 0
for i=0,(engine.Objects.Count-1) do 
	local obj = engine.Objects.Data[i]
	if NotNull(obj) then
		sum = sum + string.len(obj.UObject.Name:GetName()) 
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
		sum = sum + string.len(obj.UObject.Name:GetName()) 
	else
		skipped = skipped + 1
	end
end
print(skipped)
print(sum)
print(string.format("elapsed time: %.3f\n", os.clock() - start))