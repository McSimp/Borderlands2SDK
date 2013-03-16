local ffi = require("ffi")
local bit = require("bit")

function CountNatives()
	local nativeCount = 0
	local funcCount = 0

	for i=0,(engine.Objects.Count-1) do
		local obj = engine.Objects:Get(i)
		if IsNull(obj) then goto continue end
		if not obj:IsA(engine.Classes.UFunction) then goto continue end

		obj = ffi.cast("struct UFunction*", obj)

		funcCount = funcCount + 1

		if bit.band(obj.UFunction.FunctionFlags, 0x400) ~= 0 then
			nativeCount = nativeCount + 1
		end

		::continue::
	end

	print("Func count = " .. funcCount)
	print("Native count = " .. nativeCount)
end

function ScriptText()
	for i=0,(engine.Objects.Count-1) do
		local obj = engine.Objects:Get(i)
		if IsNull(obj) then goto continue end
		if not obj:IsA(engine.Classes.UStruct) then goto continue end

		obj = ffi.cast("struct UStruct*", obj)

		if NotNull(obj.UStruct.Text1) or NotNull(obj.UStruct.Text2) then
			print(obj:GetFullName() .. " SCRIPT TEXT")
		end

		if NotNull(obj.UStruct.Script.Data) then
			print(obj:GetFullName() .. " => " .. obj.UStruct.Script.Count)
		end

		::continue::
	end
end

function FuncCode()
	for i=0,(engine.Objects.Count-1) do
		local obj = engine.Objects:Get(i)
		if IsNull(obj) then goto continue end
		if not obj:IsA(engine.Classes.UFunction) then goto continue end

		obj = ffi.cast("struct UFunction*", obj)

		if bit.band(obj.UFunction.FunctionFlags, 0x400) == 0 and NotNull(obj.UStruct.Script.Data) then
			print(obj:GetFullName() .. " => " .. obj.UStruct.Script.Count)
		end

		::continue::
	end
end


function DumpByteCode()
	-- Function WillowGame.WillowVehicle.Turbo 
	local funcPtr = engine.Classes.AWillowVehicle.funcs.Turbo.ptr

	local out = ""
	for _,code in ipairs(funcPtr.UStruct.Script) do
		out = out .. bit.tohex(code,2) .. " "
	end

	print(funcPtr.UStruct.Script)
	print(out)
end

function GetName(index)
	return ffi.string(engine.Names:Get(index).Name)
end