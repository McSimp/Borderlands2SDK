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

ffi.cdef[[
	struct UObjectT_Data { 
		struct FPointer 	VfTableObject;
		struct UObject*		HashNext;
		struct FQWord 		ObjectFlags;
		struct UObject* 	HashOuterNext;
		struct FPointer 	StateFrame;
		struct UObject* 	Linker;
		struct FPointer 	LinkerIndex;
		int 				Index;
		int 				NetIndex;
		struct UObject* 	Outer;
		struct FName 		Name;
		struct UClass* 		Class;
		struct UObject* 	ObjectArchetype;
	};

	struct UObjectT {
		struct UObjectT_Data UObject;
	};
]]

local metaT = { __index = {} }

function metaT:__index(k)
	-- 0. Get the actual class information for this object
	local classInfo = engine._ClassesInternal[PtrToNum(self.UObject.Class)]

	-- 1. Cast this object to the right type
	local actualTypeName = "struct " .. classInfo["name"] .. "*"
	self = ffi.cast(actualTypeName, self)

	-- 2. Since we have casted, check the actual class type first
	local value = self[classInfo["name"]][k]

	local base = classInfo
	while base do
		if self[base["name"]][k] ~= nil then 
			return self[base["name"]][k]
		else
			base = base["base"]
		end
	end

	return nil
end

ffi.metatype("struct UObjectT", metaT)

local start = os.clock()
local myvar = ffi.cast("struct UIntProperty*", engine.Objects:Get(10))
io.stdout:write(tostring(myvar.UObject.Class))
--print(myvar.UObject.Class:GetName())
io.stdout:write(myvar.UProperty.Offset)
print(string.format("elapsed time: %.3f", os.clock() - start))

start = os.clock()
myvar = ffi.cast("struct UObjectT*", engine.Objects:Get(10))
io.stdout:write(tostring(myvar.Class))
--print(myvar.Class:GetName())
io.stdout:write(myvar.Offset)
print(string.format("elapsed time: %.5f", os.clock() - start))

print("Ran!")