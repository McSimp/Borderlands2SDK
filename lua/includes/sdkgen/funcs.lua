local ffi = require("ffi")
local engine = engine
local Package = SDKGen.Package

function Package:ProcessClassForFuncs(class)
	local classFuncs = {}
	local classProperty = ffi.cast("struct UProperty*", class.UStruct.Children)
	while NotNull(classProperty) do
		if classProperty:IsA(engine.Classes.UFunction) then
			self:ProcessFunction(ffi.cast("struct UFunction*", classProperty))
		end
		classProperty = ffi.cast("struct UProperty*", classProperty.UField.Next)
	end
end

function Package:ProcessFunction(func)
	
end

function Package:ProcessClasses()

	self:CreateFile("funcs")
	self:WriteFileHeader("Function structures")

	-- Foreach object, check if it's a class, then check if it's in the package.
	-- If it is, then process the class, in turn processing all the functions in it.
	for i=0,(engine.Objects.Count-1) do
		local obj = engine.Objects:Get(i)
		if IsNull(obj) then goto continue end

		local package_object = obj:GetPackageObject()
		if IsNull(package_object) then goto continue end
		if package_object ~= self.PackageObj then goto continue end

		if not obj:IsA(engine.Classes.UClass) then goto continue end

		self:ProcessClassForFuncs(obj) -- Get all the function defs

		::continue::
	end

	self:WriteCDefWrapperEnd()
	self:WriteClassMetaData()
	self:CloseFile()
end
