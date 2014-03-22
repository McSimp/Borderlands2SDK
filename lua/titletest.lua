local bit = require("bit")

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

local FUNC_HasOptionalParms = 0x00004000
local FUNC_Native = 0x00000400

function OptFuncs()
	for i=0,(engine.Objects.Count-1) do
		local obj = engine.Objects[i]
		if IsNull(obj) then goto continue end
		if obj.UObject.Class ~= engine.Classes.UFunction.static then goto continue end

		obj = ffi.cast("struct UFunction*", obj)

		if flags.IsSet(obj.UFunction.FunctionFlags, FUNC_Native) then

			local funcProperty = ffi.cast("struct UProperty*", obj.UStruct.Children)
			while NotNull(funcProperty) do
				if funcProperty:IsA(engine.Classes.UStrProperty) and flags.IsSet(funcProperty.UProperty.PropertyFlags.A, 0x10) then
					print(obj:GetFullName())
					goto continue
				end

				funcProperty = ffi.cast("struct UProperty*", funcProperty.UField.Next)
			end
		end

		::continue::
	end
end

function FuncOptCodes()
	for i=0,(engine.Objects.Count-1) do
		local obj = engine.Objects[i]
		if IsNull(obj) then goto continue end
		if obj.UObject.Class ~= engine.Classes.UFunction.static then goto continue end

		obj = ffi.cast("struct UFunction*", obj)

		local code = obj.UStruct.Script

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

function TestNewCall()
	local stack = ffi.new("struct FFrame")
	local code = ffi.new("unsigned char[128]")
	local locals = ffi.new("unsigned char[128]")

	local splitStringFunc = ffi.cast("struct UFunction*", engine.FindObject("Function Core.Object:SplitString"))
	local parmSource = ffi.cast("struct UProperty*", splitStringFunc.UStruct.Children)
	local parmDelim = ffi.cast("struct UProperty*", splitStringFunc.UStruct.Children.Next)

	ffi.fill(code, 128, 0)
	ffi.fill(locals, 128, 0)

	code[0] = 0x1C -- EX_FinalFunction
	local funcPtr = ffi.cast("struct UFunction**", code + 1)
	funcPtr[0] = splitStringFunc
	code[9] = 0x29 -- EX_NativeParm
	local prop1 = ffi.cast("struct UProperty**", code + 10)
	prop1[0] = parmSource
	code[18] = 0x29 -- EX_NativeParm
	local prop2 = ffi.cast("struct UProperty**", code + 19)
	prop2[0] = parmDelim
	code[27] = 0x4A -- EX_EmptyParmValue
	code[28] = 0x16 -- EX_EndFunctionParms

	stack.Code = code

	local sourceStr = FString.GetFromLuaString("Shazbot lol!")
	local delim = FString.GetFromLuaString("lo")

	local localSourceStr = ffi.cast("struct FString*", locals)
	localSourceStr[0] = sourceStr
	local localDelim = ffi.cast("struct FString*", locals + 12)
	localDelim[0] = delim

	stack.VfTable = ffi.cast("void*", 0x16BF480)
	stack.bAllowSuppression = true
	stack.bSuppressEventTag = false
	stack.bAutoEmitLineTerminator = true
	print(engine.Classes.UObject.static)
	stack.Node = ffi.cast("struct UStruct*", engine.Classes.UObject.static)
	stack.Object = ffi.cast("struct UObject*", LocalPC())
	stack.Locals = locals
	stack.PreviousFrame = nil
	stack.OutParms = nil

	print(stack.Code)
	print(stack:GetFuncCodeHex())
	print(stack:GetLocalsHex(50))

	local resultStorage = ffi.new("unsigned char[128]")
	stack:Step(stack.Object, resultStorage)

	local arrayAddr = ffi.cast("void**", resultStorage)
	print(arrayAddr[0])
	ffi.C.LUAFUNC_AddAllocationWatch(arrayAddr[0])

	local out = ""
	for i=0,100 do
		out = out .. bit.tohex(resultStorage[i], 2) .. " "
	end

	print(out)
	print(stack.Code)
	print(stack:GetLocalsHex(50))
end

function TestNewFuncMT()
	local result = LocalPC():SplitString("Shazbot lol!")
	print(result)
	for k,v in pairs(result) do
		print(k,v,v.Data)
	end
end
