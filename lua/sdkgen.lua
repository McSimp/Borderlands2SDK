local ffi = require("ffi")

local FILE_HEADER = [[
-- ###################################
-- # Borderlands 2 SDK
-- # Package: %s
-- # File Contents: %s
-- ###################################

]]

SDKGen = { Package = {} }

function SDKGen.SortProperty(propA, propB)
	-- Note that propA and propB should already be UProperty*

	-- First check if they are booleans and share the same offset. Compare bitmasks if so.
	-- Otherwise just compare their offset in the struct.
	if 	propA.UProperty.Offset == propB.UProperty.Offset
		and propA:IsA(engine.Classes.UBoolProperty)
		and propB:IsA(engine.Classes.UBoolProperty)
	then
		propA = ffi.cast("struct UBoolProperty*", propA)
		propB = ffi.cast("struct UBoolProperty*", propB)

		return propA.UBoolProperty.BitMask < propB.UBoolProperty.BitMask
	else
		return propA.UProperty.Offset < propB.UProperty.Offset
	end
end

local types = {
	ByteProperty = "unsigned char",
	IntProperty = "int",
	FloatProperty = "float",
	BoolProperty = "unsigned long", -- No bool in C AFAIK
	StrProperty = "struct FString",
	NameProperty = "struct FName",
	DelegateProperty = "struct FStringDelegate",
	ObjectProperty = "struct %s*",
	ClassProperty = "struct %s*",
	ComponentProperty = "struct %s*",
	InterfaceProperty = "struct FScriptInterface",
	StructProperty = "struct type",
	ArrayProperty = "struct TArray"
	--MapProperty = ...
}

function SDKGen.GetPropertyType(prop)
	local propType = types[prop.UObject.Class:GetName()]
	if not propType then return false end

	if prop:IsA(engine.Classes.UClassProperty) then
		prop = ffi.cast("struct UClassProperty*", prop)
		propType = string.format(propType, prop.UClassProperty.MetaClass:GetCName())
	elseif prop:IsA(engine.Classes.UObjectProperty) then -- Covers UComponentProp too
		prop = ffi.cast("struct UObjectProperty*", prop)
		propType = string.format(propType, prop.UObjectProperty.PropertyClass:GetCName())
	end

	return propType
end

local Package = SDKGen.Package
Package.__index = Package

function Package.new(package_object)
	return setmetatable({ PackageObj = package_object }, Package)
end

function Package:CreateFile(folder)
	local package_name = self.PackageObj:GetName()
	self.File = io.open("D:\\dev\\bl\\Borderlands2SDK\\bin\\Debug\\lua\\sdkgen\\" .. folder .. "\\" .. package_name .. ".lua", "w+")
end

function Package:CloseFile()
	if self.File then
		self.File:close()
		self.File = nil
	end
end

function Package:Close()
	self:CloseFile()
end

function Package:WriteFileHeader(contents)
	self.File:write(string.format(FILE_HEADER, self.PackageObj:GetName(), contents))
end

include("sdkgen_structs.lua")

function ProcessPackages()

	local processed = {}

	for i=0,(engine.Objects.Count-1) do

		local obj = engine.Objects:Get(i)
		if IsNull(obj) then goto continue end
		if not obj:IsA(engine.Classes.UClass) then goto continue end
		
		local package_object = obj:GetPackageObject()
		if IsNull(package_object) then goto continue end
		if table.contains(processed, package_object) then goto continue end

		local pkg = Package.new(package_object)
		
		pkg:ProcessScriptStructs()

		pkg:Close()

		table.insert(processed, package_object)

		::continue::
	end

end


ProcessPackages()
