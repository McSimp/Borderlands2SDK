local ffi = require("ffi")

--engineHook.Remove(engine.Classes.UGearboxAccountData.funcs.ReloadEntitlements, "LolDev")
engineHook.Add(engine.Classes.UCustomizationDefinition.funcs.GetAvailableCustomizationsForPlayer, "LolDev", function(PC, RequiredType, bDebugAllowLocked)
	print("GetAvailableCustomizationsForPlayer called")
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

local obj = engine.Objects:Get(160043)
obj = ffi.cast("struct UGearboxAccountData*", obj)

