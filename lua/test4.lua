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


local function GetWeaponTypes()
	local weaponTypes = {}

	for i=0,(engine.Objects.Count-1) do
		local obj = engine.Objects:Get(i)
		if IsNull(obj) then goto continue end
		if obj.UObject.Class ~= engine.Classes.UWeaponTypeDefinition.static then goto continue end

		obj = ffi.cast("struct UWeaponTypeDefinition*", obj)

		table.insert(weaponTypes, obj)

		::continue::
	end

	table.remove(weaponTypes, 1)

	return weaponTypes
end

local balanceDefs = {}
local function GetAllBalanceDefs()
	if #balanceDefs ~= 0 then
		return balanceDefs
	end

	for i=0,(engine.Objects.Count-1) do
		local obj = engine.Objects:Get(i)
		if IsNull(obj) then goto continue end
		if obj.UObject.Class ~= engine.Classes.UWeaponBalanceDefinition.static then goto continue end

		obj = ffi.cast("struct UWeaponBalanceDefinition*", obj)

		table.insert(balanceDefs, obj)

		::continue::
	end

	return balanceDefs
end

local function GetBalanceDefs(wepType)
	local allDefs = GetAllBalanceDefs()

	local thisTypeDefs = {}

	-- First insert the very base so we can check the bases of other balance defs
	for _,v in ipairs(allDefs) do
		if v.InventoryDefinition == wepType then
			table.insert(thisTypeDefs, v)
		end
	end

	-- Now do it for the rest of them, which could inherit from the base
	for _,v in ipairs(allDefs) do
		-- Check if it has a base which we know is a balance def
		-- for this type, and if it does, add it to the list.
		
		local baseDef = v.BaseDefinition
		while NotNull(baseDef) do
			if table.contains(thisTypeDefs, baseDef) then
				table.insert(thisTypeDefs, v)
				goto continue
			end

			baseDef = baseDef.BaseDefinition
		end

		::continue::
	end

	return thisTypeDefs
end

local function GetManufacturers(balanceDefs)
	-- For all the balance defs, insert all the elements of the Manufacturers
	-- array into a table
	local manufacturers = {}

	for _,v in ipairs(balanceDefs) do
		if v.Manufacturers.Count ~= 0 then
			for _,mf in ipairs(v.Manufacturers) do
				table.insert(manufacturers, mf.Manufacturer)
			end
		end
	end

	return manufacturers
end

local function GetParts(partList)
	local ret = {}
	local parts = partList.UWeaponPartListDefinition.WeightedParts

	for _,v in ipairs(parts) do
		table.insert(ret, v)
	end

	return ret
end


function TestingShit(idx)
	local types = GetWeaponTypes()
	local weaponTypeDef = types[idx]
	local typeBalanceDefs = GetBalanceDefs(weaponTypeDef)
	print("Doing for: " .. weaponTypeDef:GetFullName())


	print("Balance defs")
	for _,v in ipairs(typeBalanceDefs) do
		print(v:GetFullName())
	end

	print("Manufacturers")

	local manufacturers = GetManufacturers(typeBalanceDefs)

	for _,v in ipairs(manufacturers) do
		print(v:GetFullName())
	end

	print("Body parts")

	print(weaponTypeDef.BodyParts)
--[[
	local bodyParts = GetParts(weaponTypeDef.BodyParts)

	for _,v in ipairs(bodyParts) do
		print(v:GetFullName())
	end
]]
end

local function CleanupOldInspect(gfx)
	local mesh = ffi.cast("struct UActorComponent*", gfx.MyInspectionMesh)
	gfx.WPCOwner.Pawn:DetachComponent(mesh)

	--gfx.MyInspectionMesh = nil
end

function InspectRandomWeapon()
	local gfx = engine.FindObjectExactClass("ItemInspectionGFxMovie Transient.ItemInspectionGFxMovie", engine.Classes.UItemInspectionGFxMovie)
	print("Found Inspect movie: " .. gfx:GetFullName())

	print("Cleaning it up")
	CleanupOldInspect(gfx)

	print("Generating random weapon data")
	local types = GetWeaponTypes()


	local thing = engine.Objects:Get(index)
	thing = ffi.cast("struct AWillowInventory*", thing)
	print("Calling InspectItem on: " .. thing:GetFullName())
	gfx:InspectItem(thing)
end

--[[
struct FWeaponDefinitionData {
	struct UWeaponTypeDefinition* WeaponTypeDefinition; // 0x0 (0x4)
	struct UInventoryBalanceDefinition* BalanceDefinition; // 0x4 (0x4)
	struct UManufacturerDefinition* ManufacturerDefinition; // 0x8 (0x4)
	int ManufacturerGradeIndex; // 0xC (0x4)
	struct UWeaponPartDefinition* BodyPartDefinition; // 0x10 (0x4)
	struct UWeaponPartDefinition* GripPartDefinition; // 0x14 (0x4)
	struct UWeaponPartDefinition* BarrelPartDefinition; // 0x18 (0x4)
	struct UWeaponPartDefinition* SightPartDefinition; // 0x1C (0x4)
	struct UWeaponPartDefinition* StockPartDefinition; // 0x20 (0x4)
	struct UWeaponPartDefinition* ElementalPartDefinition; // 0x24 (0x4)
	struct UWeaponPartDefinition* Accessory1PartDefinition; // 0x28 (0x4)
	struct UWeaponPartDefinition* Accessory2PartDefinition; // 0x2C (0x4)
	struct UWeaponPartDefinition* MaterialPartDefinition; // 0x30 (0x4)
	struct UWeaponNamePartDefinition* PrefixPartDefinition; // 0x34 (0x4)
	struct UWeaponNamePartDefinition* TitlePartDefinition; // 0x38 (0x4)
	int GameStage; // 0x3C (0x4)
	int UniqueId; // 0x40 (0x4)
};

struct AInventory_Data {
	struct AInventory* Inventory; // 0x188 (0x4)
	struct AInventoryManager* InvManager; // 0x18C (0x4)
	struct FString ItemName; // 0x190 (0xC)
	bool bDropOnDeath : 1; // 0x19C (0x4)
	bool bReadied : 1; // 0x19C (0x4)
	bool bDelayedSpawn : 1; // 0x19C (0x4)
	bool bPredictRespawns : 1; // 0x19C (0x4)
	unsigned char Unknown0[0x3]; // BITFIELD FIX
	float RespawnTime; // 0x1A0 (0x4)
	float MaxDesireability; // 0x1A4 (0x4)
	struct FString PickupMessage; // 0x1A8 (0xC)
	struct ULocalMessage* MessageClass; // 0x1B4 (0x4)
	struct USoundCue* PickupSound; // 0x1B8 (0x4)
	struct ADroppedPickup* DroppedPickupClass; // 0x1BC (0x4)
	struct UPrimitiveComponent* DroppedPickupMesh; // 0x1C0 (0x4)
	struct UPrimitiveComponent* PickupFactoryMesh; // 0x1C4 (0x4)
};

struct AWillowInventory_Data {
	struct FPointer VfTable_IIBalancedActor; // 0x1C8 (0x4)
	struct FPointer VfTable_IIAttributeSlotEffectProvider; // 0x1CC (0x4)
	int MonetaryValue; // 0x1D0 (0x4)
	float MonetaryValueModifierTotal; // 0x1D4 (0x4)
	int Quantity; // 0x1D8 (0x4)
	int RarityLevel; // 0x1DC (0x4)
	int ExpLevel; // 0x1E0 (0x4)
	int GameStage; // 0x1E4 (0x4)
	int AwesomeLevel; // 0x1E8 (0x4)
	struct UObject* AdditionalQueryInterfaceSource; // 0x1EC (0x4)
	float ClonedForSharing; // 0x1F0 (0x4)
	int LastCanBeUsedByResult; // 0x1F4 (0x4)
	struct FName ZippyFrame; // 0x1F8 (0x8)
	struct FString ItemFrame; // 0x200 (0xC)
	struct FName ElementalFrame; // 0x20C (0x8)
	struct FName SourceDefinitionName; // 0x214 (0x8)
	struct FName SourceResponsibleName; // 0x21C (0x8)
	unsigned char ItemLocation; // 0x224 (0x1)
	unsigned char Mark; // 0x225 (0x1)
	bool bShopsHaveInfiniteQuantity : 1; // 0x228 (0x4)
	bool bOnlyCompareStatsForMatchingAttributes : 1; // 0x228 (0x4)
	unsigned char Unknown0[0x3]; // BITFIELD FIX
	struct FAttributeSlotData AttributeSlots[19]; // 0x22C (0x5F0)
	float ReplicatedAttributeSlotModifierValues[19]; // 0x81C (0x4C)
	struct UGBXDefinition* RuntimeAttributeSlotSkill; // 0x868 (0x4)
	float TempStatModifier; // 0x86C (0x4)
	float TempStatModifierBaseValue; // 0x870 (0x4)
	struct TArray_UAttributeModifierPtr_ TempStatModifierModifierStack; // 0x874 (0xC)
	struct TArray_FAppliedAttributeEffect_ AppliedAttributeSlotEffects; // 0x880 (0xC)
	struct TArray_AActorPtr_ ExternalLikenessConsumers; // 0x88C (0xC)
};
]]