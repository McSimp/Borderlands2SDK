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
--local testpoint = ffi.cast("struct UArrayProperty*", 0x04149918)

--print(engine.Objects:Get(10):GetFullName())
--print(testpoint.UObject.Class)
--print(testpoint.UArrayProperty.Inner:GetName())

--[[
for i=0,(engine.Objects.Count-1) do 
	local obj = engine.Objects:Get(i)
	if NotNull(obj) then
		if obj:IsA(engine.Classes.UStruct) then
			obj = ffi.cast("struct UStruct*", obj)
			print(obj)
			print(obj:GetFullName())
			print(obj.UStruct.PropertySize)
		end
	end
end
]]
--[[
print(engine.Objects:Get(10).UObject.Class)
print(engine.Objects:Get(10):GetName())
print(tonumber(ffi.cast("unsigned int", engine.Objects:Get(10).UObject.Class)))
print(tonumber(0x025ab418))
]]

local bit = require("bit")

ffi.cdef[[
struct UObject_execGetPackageName_Parms
{
	struct FName                                       ReturnValue;                                      		// 0x0000 (0x0008) [0x0000000000000580]              ( CPF_Parm | CPF_OutParm | CPF_ReturnParm )
};

typedef void (__thiscall *tProcessEvent) (struct UObject*, struct UFunction*, void*, void*);
]]

--[[
local func = ffi.cast("tProcessEvent", 0x65C820)

function SetSubtitle()
	local pc = engine.FindObject("WillowPlayerController TheWorld.PersistentLevel.WillowPlayerController")
	if IsNull(pc) then return end
	print(pc)

	local getengver = engine.Objects:Get(5374)
	getengver = ffi.cast("struct UFunction*", getengver)
	print(getengver)

	local parms = ffi.new("struct UObject_execGetPackageName_Parms")
	print(bit.tohex(getengver.UFunction.FunctionFlags))
	--getengver.UFunction.FunctionFlags = bit.band(getengver.UFunction.FunctionFlags, bit.bnot(0x400))
	print(bit.tohex(getengver.UFunction.FunctionFlags))
	print(parms)

	print("Calling it now")
	func(pc, getengver, parms, nil)

	getengver.UFunction.FunctionFlags = bit.bor(getengver.UFunction.FunctionFlags, 0x400)
	print(bit.tohex(getengver.UFunction.FunctionFlags))
	print(parms.ReturnValue.Index)
end


SetSubtitle()
]]

print(ffi.sizeof("struct ing"))