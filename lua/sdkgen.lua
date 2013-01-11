local ffi = require("ffi")

local FILE_HEADER = [[
-- ###################################
-- # Borderlands 2 SDK
-- # Package: %s
-- # File Contents: %s
-- ###################################

]]

SDKGen = { Package = {} }

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
