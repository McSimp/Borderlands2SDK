local ffi = require("ffi")
local bit = require("bit")
local engine = engine
local Package = SDKGen.Package

local CPF_OptionalParm = 0x0000000000000010
local CPF_Parm = 0x0000000000000080
local CPF_OutParm = 0x0000000000000100
local CPF_SkipParm = 0x0000000000000200
local CPF_ReturnParm = 0x0000000000000400

print(CPF_OutParm)

function Package:ProcessClassForFuncs(class)
	self.File:write(string.format("c[%q][3] = {\n", class:GetCName()))

	local classFuncs = {}
	local classProperty = ffi.cast("struct UProperty*", class.UStruct.Children)
	while NotNull(classProperty) do
		if classProperty:IsA(engine.Classes.UFunction) then
			self:ProcessFunction(ffi.cast("struct UFunction*", classProperty))
		end
		classProperty = ffi.cast("struct UProperty*", classProperty.UField.Next)
	end

	self.File:write("}\n\n")
end

local function ProcessRetval(field)
	local text = "\t\t\t{\n"

	-- Name
	text = text .. string.format("\t\t\t\tname = %q,\n", field:GetName())

	-- Type
	local propData = SDKGen.GetPropertyTypeData(field)
	if not propData then return "" end
	local propType = SDKGen.GetPropertyType(field)

	if not propData.basic then -- basic means it's not cdata
		text = text .. string.format("\t\t\t\tcType = ffi.typeof(%q),\n", propType)
	end

	text = text .. string.format("\t\t\t\tcastTo = ffi.typeof(%q),\n", propType .. "*")

	-- Offset and closing bracket
	text = text .. string.format("\t\t\t\toffset = %d\n\t\t\t},\n", field.UProperty.Offset)

	return text
end

function Package:ProcessFunction(func)
	-- First, we'll get all the fields and sort them
	local fields = {}
	local funcProperty = ffi.cast("struct UProperty*", func.UStruct.Children)
	while NotNull(funcProperty) do
		if funcProperty.UProperty.ElementSize > 0 then
			table.insert(fields, funcProperty)
		end

		funcProperty = ffi.cast("struct UProperty*", funcProperty.UField.Next)
	end

	table.sort(fields, SDKGen.SortProperty)

	-- Now we'll go through them and separate them into args and return values
	local args = {}
	local retvals = ""

	for _,field in ipairs(fields) do
		local flags = field.UProperty.PropertyFlags.A
		print(string.format("%s = 0x%X", field:GetName(), flags))
		if bit.band(flags, CPF_OutParm) ~= 0 then
			-- If it's the return value, we want that first in the retvals list
			if bit.band(flags, CPF_ReturnParm) ~= 0 then
				retvals = ProcessRetval(field) .. retvals
			else
				retvals = retvals .. ProcessRetval(field)
			end
		end
	end

	self.File:write(string.format("\t[%q] = {\n", func:GetName()))

	self.File:write("\t\tretvals = {\n")
	self.File:write(retvals)
	self.File:write("\t\t}\n")

	self.File:write("\t},\n")
end

function Package:ProcessFunctions()
	self:CreateFile("funcs")
	self:WriteFileHeader("Function structures")
	self.File:write("local c = g_loadedClasses\n\n")

	-- Foreach object, check if it's a class, then check if it's in the package.
	-- If it is, then process the class, in turn processing all the functions in it.
	for i=0,(engine.Objects.Count-1) do
		local obj = engine.Objects:Get(i)
		if IsNull(obj) then goto continue end

		local package_object = obj:GetPackageObject()
		if IsNull(package_object) then goto continue end
		if package_object ~= self.PackageObj then goto continue end

		if not obj:IsA(engine.Classes.UClass) then goto continue end

		self:ProcessClassForFuncs(ffi.cast("struct UClass*", obj)) -- Get all the function defs

		::continue::
	end

	self:WriteClassMetaData()
	self:CloseFile()
end
