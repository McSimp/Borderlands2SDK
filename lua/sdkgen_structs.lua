local ffi = require("ffi")
local Package = SDKGen.Package
local GeneratedStructs = {}
local DefaultStruct = engine.FindObject("ScriptStruct Core.Default__ScriptStruct")
local STRUCT_ALIGN = 4

local ScriptStruct = {}
ScriptStruct.__index = ScriptStruct

function ScriptStruct.new(obj)
	return setmetatable({ Struct = ffi.cast("struct UScriptStruct*", obj), UnknownDataIndex = 0 }, ScriptStruct)
end

function ScriptStruct:GeneratePrereqs(inPackage)

	local scriptStruct = self.Struct
	local structPackage = scriptStruct:GetPackageObject()

	if IsNull(structPackage) or structPackage ~= inPackage then
		return
	end

	if scriptStruct == DefaultStruct then return end -- Skip the default because it's a dummy
	if table.contains(GeneratedStructs, scriptStruct) then return end -- Skip it if we've already made it

	-- First, check to see if this struct has a base. If it does, make sure we have generated it before
	-- we move on.

	local base = scriptStruct.UStruct.SuperField

	if 	NotNull(base)
		and base ~= scriptStruct
		and not table.contains(GeneratedStructs, base) 
	then
		print(scriptStruct:GetFullName() .. " has base " .. base:GetFullName())
		ScriptStruct.new(base):GeneratePrereqs(inPackage)
	end

	-- Next, check to see if there are any members of this struct which we haven't yet generated.
	-- If there are, generate them before moving on. There are two cases here: a plain old struct,
	-- and a TArray of structs. There could also be TMap, but this data structure doesn't seem to
	-- be present in BL2.

	local structField = ffi.cast("struct UProperty*", scriptStruct.UStruct.Children)
	while NotNull(structField) do -- Foreach property in the struct

		if structField:IsA(engine.Classes.UStructProperty) then -- If it's a plain old struct
			structField = ffi.cast("struct UStructProperty*", structField)

			local fieldStruct = structField.UStructProperty.Struct

			-- If the struct for this field hasn't been generated, DO IT NOW.
			if 	fieldStruct ~= scriptStruct 
				and not table.contains(GeneratedStructs, fieldStruct) 
			then
				ScriptStruct.new(structField.UStructProperty.Struct):GeneratePrereqs(inPackage)
			end
		elseif structField:IsA(engine.Classes.UArrayProperty) then
			structField = ffi.cast("struct UArrayProperty*", structField)

			local innerProperty = structField.UArrayProperty.Inner
			if innerProperty:IsA(engine.Classes.UStructProperty) then
				local innerStruct = ffi.cast("struct UStructProperty*", innerProperty).UStructProperty.Struct

				if 	NotNull(innerStruct)
					and innerStruct ~= scriptStruct
					and not table.contains(GeneratedStructs, innerStruct) 
				then
					ScriptStruct.new(innerStruct):GeneratePrereqs(inPackage)
				end
			end
		end

		-- TMap would be here if BL needed it

		structField = ffi.cast("struct UProperty*", structField.UField.Next)
	end

	-- All the requisite structs should have been generated by now, so we can generate this one
	self:GenerateDefinition()

end

function ScriptStruct:GetFieldsSize()
	return self.Struct.UStruct.PropertySize
end

function ScriptStruct:GenerateDefinition()

	local scriptStruct = self.Struct

	print("[SDKGen] Struct " .. scriptStruct:GetFullName())

	-- Start by defining the struct with its name
	local structText = "struct " .. scriptStruct:GetCName() .. " {\n"

	-- Check if this struct has a base which it inherits from. If it does, instead of doing
	-- some hacky C struct inheritance, just put all the base fields straight into the def
	-- for this struct.
	local base = scriptStruct.UStruct.SuperField
	local actualStart = 0
	if NotNull(base) and base ~= scriptStruct then
		local baseStruct = ScriptStruct.new(base)
		structText = structText .. baseStruct:FieldsToC(0)
		actualStart = actualStart + baseStruct:GetFieldsSize()
	end

	structText = structText .. self:FieldsToC(actualStart)
	structText = structText .. "};"

	table.insert(GeneratedStructs, scriptStruct)

	print(structText)
end

function ScriptStruct:FieldsToC(startingOffset)

	local scriptStruct = self.Struct

	-- Foreach property, add them into the properties array
	local properties = {}
	local structProperty = ffi.cast("struct UProperty*", scriptStruct.UStruct.Children)
	while NotNull(structProperty) do
		if structProperty.UProperty.ElementSize > 0 and not structProperty:IsA(engine.Classes.UScriptStruct) then
			table.insert(properties, structProperty)
		end

		structProperty = ffi.cast("struct UProperty*", structProperty.UField.Next)
	end

	-- Next, sort the properties according to their offset in the struct. When dealing with
	-- boolean types, we need the one with the smallest bitmask first.
	table.sort(properties, SDKGen.SortProperty)

	local out = ""
	for _,property in ipairs(properties) do

		if startingOffset < property.UProperty.Offset then
			print("Had to miss an offset")
			out = out .. self:MissedOffset(startingOffset, (property.UProperty.Offset - startingOffset))
		end

		local typeof = SDKGen.GetPropertyType(property) -- Handle false return

		out = out .. "\t" .. typeof .. " ".. property:GetName() .. "; // Offset = " .. tostring(property.UProperty.Offset) .. " Size = " .. tostring(property.UProperty.ElementSize) .. " ArrayDim = " .. tostring(property.UProperty.ArrayDim) .. "\n"
	
		startingOffset = property.UProperty.Offset + (property.UProperty.ElementSize * property.UProperty.ArrayDim)
	end

	return out
end

function ScriptStruct:MissedOffset(at, missedSize)
	if missedSize < STRUCT_ALIGN then return "" end

	self.UnknownDataIndex = self.UnknownDataIndex + 1

	return string.format("\tunsigned char Unknown%d[0x%X]; // 0x%X (0x%X) MISSED OFFSET\n", 
		self.UnknownDataIndex,
		missedSize,
		at,
		missedSize)
end

function Package:ProcessScriptStructs()

	self:CreateFile("structs")
	self:WriteFileHeader("Script Structs")

	-- Foreach object, check if it's a scriptstruct, then check if it's in the package.
	-- If it is, then process the struct
	for i=0,(engine.Objects.Count-1) do

		local obj = engine.Objects:Get(i)
		if IsNull(obj) then goto continue end

		local package_object = obj:GetPackageObject()
		if IsNull(package_object) then goto continue end
		if package_object ~= self.PackageObj then goto continue end

		if not obj:IsA(engine.Classes.UScriptStruct) then goto continue end

		ScriptStruct.new(obj):GeneratePrereqs(self.PackageObj) -- Generate the requisite structs then generate this one

		::continue:: -- INSERT COIN TO CONTINUE
	end

	self:CloseFile()

end



function Package:CheckForSameName(checkobj)

	for i=0,(engine.Objects.Count-1) do

		local obj = engine.Objects:Get(i)
		if IsNull(obj) then goto continue end
		if not obj:IsA(engine.Classes.UScriptStruct) then goto continue end

		if obj ~= checkobj and obj:GetFullName() == checkobj:GetFullName() then

			print("FOUND THE SAME NAME FOR " .. name)
			return

		end

		::continue::
	end

end
