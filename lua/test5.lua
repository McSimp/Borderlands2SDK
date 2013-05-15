local ffi = require("ffi")

scriptHook.Remove(engine.Classes.UItemInspectionGFxMovie.funcs.InspectItem, "InspectHook")
scriptHook.Add(engine.Classes.UItemInspectionGFxMovie.funcs.InspectItem, "InspectHok", function(Object, Stack, Result, Function)
	print("InspectItem called")

	local thing = Stack:GetStruct("struct AWillowInventory*")
	print(thing:GetFullName())
	print(thing.Index)
	
	--[[
	print("WillowInventory members")

	print(thing.MonetaryValue)
	print(thing.Quantity)
	print(thing.RarityLevel)
	print(thing.ExpLevel)
	print(thing.GameStage)
	print(thing.AwesomeLevel)
	print(thing.ClonedForSharing)
	print(thing.ItemLocation)
	print(thing.Mark)

	print(thing.ZippyFrame:GetName())
	print(thing.ItemFrame:GetLuaString())
	print(thing.ElementalFrame:GetName())
	print(thing.SourceDefinitionName:GetName())
	print(thing.SourceResponsibleName:GetName())

	print("WillowWeapon members")
	print(thing.ShotCost)
	print(thing.ShotCostBaseValue)
	print(thing.AdditionalRicochets)
	print(thing.AdditionalRicochetsBaseValue)
	print(thing.ClipSize)
	print(thing.ClipSizeBaseValue)
	print(thing.ReloadTime)
	print(thing.ReloadTimeBaseValue)
	print(thing.bUseWeaponMelee)
	]]

	print(thing:GenerateHumanReadableName():GetLuaString())

end)

scriptHook.Remove(engine.Classes.AWillowWeapon.funcs.InitializeFromDefinitionData, "InitWepHook")
scriptHook.Add(engine.Classes.AWillowWeapon.funcs.InitializeFromDefinitionData, "InitWepHook", function(Object, Stack, Result, Function)
	print("InitializeFromDefinitionData called")

	local wepDef = Stack:GetStruct("struct FWeaponDefinitionData")
	local querySource = Stack:GetObject("struct UObject*")
	local selectNameParts = Stack:GetBool()

	print(wepDef.WeaponTypeDefinition:GetFullName())
	print(querySource:GetFullName())
	print(selectNameParts)
end)

scriptHook.Remove(engine.Classes.UInventoryBalanceDefinition.funcs.GetInventoryPartListCollection, "ListCollection")
scriptHook.Add(engine.Classes.UInventoryBalanceDefinition.funcs.GetInventoryPartListCollection, "ListCollection", function(Object, Stack, Result, Function)
	print("GetInventoryPartListCollection called")

	local arg1 = Stack:GetObject("struct UObject*")
	local arg2 = Stack:GetObject("struct UObject*")
	local arg3 = Stack:GetInt()

	print(arg1:GetFullName())
	print(arg2:GetFullName())
	print(arg3)
end)