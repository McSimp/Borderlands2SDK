-- Good for seeing how loot/weapons work in game!
function PrintPatches()
	local ssc = engine.Objects[180861]

	print(ssc.ServiceName)
	print(ssc.ConfigurationGroup)
	print(ssc.OverrideUrl)

	for k,v in pairs(ssc.Values) do
		print(ssc.Keys[k], v)
	end
end

local ffi = require("ffi")

function GetName(obj)
	if obj == nil then return "None" end

	local nameEntry = engine.Names[obj.Name.Index]
	local str = ffi.string(nameEntry.Name)

	if obj.Name.Number ~= 0 then
		str = str .. "_" .. tostring(obj.Name.Number - 1)
	end

	return str
end

function GetPathName(obj, result)
	if obj ~= nil then
		local outer = obj.Outer
		if outer ~= nil then
			result = GetPathName(outer, result)

			if outer.Class ~= engine.Classes.UPackage.static and outer.Outer.Class == engine.Classes.UPackage.static then
				result = result .. ":"
			else
				result = result .. "."
			end
		end

		result = result .. GetName(obj)
	else
		result = result .. "None"
	end

	return result
end

function GetFullName(obj)
	if obj == nil then return "None" end
	local result = GetName(obj.Class) .. " "
	result = GetPathName(obj, result)
	return result
end
