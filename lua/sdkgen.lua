local ffi = require("ffi")

function table.contains(table, element)
	for _,v in pairs(table) do
		if v == element then
			return true
		end
	end
	return false
end

local fileheader = [[
-- ###################################
-- # Borderlands 2 SDK
-- # Package: %s
-- # File Contents: %s
-- ###################################

]]

local Package = {}
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
	self.File:write(string.format(fileheader, self.PackageObj:GetName(), contents))
end

function Package:ProcessScriptStructs()

	self:CreateFile("structs")
	self:WriteFileHeader("Script Structs")

	for i=0,(engine.Objects.Count-1) do

		local obj = engine.Objects:Get(i)
		if IsNull(obj) then goto continue end
		if not obj:IsA(engine.Classes.UScriptStruct) then goto continue end
		obj = ffi.cast()

		local package_object = obj:GetPackageObject()
		if IsNull(package_object) then goto continue end

		if package_object == self.PackageObj then

			print("I would generate for " .. obj:GetName())
			if NotNull(obj.UStruct.SuperField) then
				print("\tParent = " .. obj.UStruct.SuperField:GetName())
			end

		end

		::continue::
	end

	self:CloseFile()

end

function Package:GenerateScriptStructPre(script_struct)

	

end

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
