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

local FUNC_HasOptionalParms = 0x00004000
local FUNC_Native = 0x00000400

function OptFuncs()
	for i=0,(engine.Objects.Count-1) do
		local obj = engine.Objects[i]
		if IsNull(obj) then goto continue end
		if obj.UObject.Class ~= engine.Classes.UFunction.static then goto continue end

		obj = ffi.cast("struct UFunction*", obj)

		if flags.IsSet(obj.UFunction.FunctionFlags, FUNC_HasOptionalParms)
		and not flags.IsSet(obj.UFunction.FunctionFlags, FUNC_Native) then
			print(obj:GetFullName())
		end

		::continue::
	end
end

function PrintCode(idx)
	local func = ffi.cast("struct UFunction*", engine.Objects[idx])
	local code = func.UStruct.Script

	local parms = ""
	for i=0,(code.Count-1) do
		parms = parms .. string.format("%s ", bit.tohex(code[i], 2))
	end
	print(parms)
end

local ffi = require("ffi")

function DebugProperties(className)
	local class = engine.Classes[className].static

	local properties = {}
	local classProperty = ffi.cast("struct UProperty*", class.UStruct.Children)
	while NotNull(classProperty) do
		if 	classProperty.UProperty.ElementSize > 0
			and not classProperty:IsA(engine.Classes.UConst) -- Consts and enums are in children
			and not classProperty:IsA(engine.Classes.UEnum)
		then
			table.insert(properties, classProperty)
		end

		classProperty = ffi.cast("struct UProperty*", classProperty.UField.Next)
	end

	for k,property in ipairs(properties) do
		print(property:GetName())
		print(property.UProperty.ElementSize, property.UProperty.ArrayDim)
	end
end
