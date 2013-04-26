local ffi = require("ffi")
local bit = require("bit")

scriptHook.Remove(engine.Classes.UCustomizationDefinition.funcs.GetAvailableCustomizationsForPlayer, "LolDev")
scriptHook.Add(engine.Classes.UCustomizationDefinition.funcs.GetAvailableCustomizationsForPlayer, "LolDev", function(Object, Stack, Result, Function)
	print("GetAvailableCustomizationsForPlayer called")
	for i=1,10 do
		print(bit.tohex(Stack.Code[i]))
	end
end)

--[[
for i=0,(engine.Objects.Count-1) do

	local obj = engine.Objects:Get(i)
	if IsNull(obj) then goto continue end
	if not obj:IsA(engine.Classes.UGearboxAccountData) then goto continue end

	obj = ffi.cast("struct UGearboxAccountData*", obj)

	print(obj:GetFullName() .. " => " .. obj.Index)

	::continue::
end
]]
