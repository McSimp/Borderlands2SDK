local ffi = require("ffi")
math.randomseed(os.time())

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
	local parts = partList.WeightedParts

	for _,v in ipairs(parts) do
		table.insert(ret, v.Part)
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

	print("parts")
	local chosenBalance = typeBalanceDefs[1]

	local theList = chosenBalance:GetInventoryPartListCollection(
		ffi.cast("struct UClass*", engine.Classes.UWeaponPartListCollectionDefinition.static),
		manufacturers[1],
		20)

	print(theList)
	print(theList:GetFullName())

	print("Body Parts")

	local bodyParts = GetParts(theList.BodyPartData)
	for _,v in ipairs(bodyParts) do
		print(v:GetFullName())
	end

	print("Grip Parts")

	local gripParts = GetParts(theList.GripPartData)
	for _,v in ipairs(gripParts) do
		print(v:GetFullName())
	end

	print("Barrel Parts")

	local barrelParts = GetParts(theList.BarrelPartData)
	for _,v in ipairs(barrelParts) do
		print(v:GetFullName())
	end

	print("Sight Parts")

	local sightParts = GetParts(theList.SightPartData)
	for _,v in ipairs(sightParts) do
		print(v:GetFullName())
	end

	print("Stock Parts")

	local stockParts = GetParts(theList.StockPartData)
	for _,v in ipairs(stockParts) do
		print(v:GetFullName())
	end

	print("Elemental Parts")

	local elementalParts = GetParts(theList.ElementalPartData)
	for _,v in ipairs(elementalParts) do
		print(v:GetFullName())
	end

	print("Acc 1 Parts")

	local acc1Parts = GetParts(theList.Accessory1PartData)
	for _,v in ipairs(acc1Parts) do
		print(v:GetFullName())
	end

	print("Acc 2 Parts")

	local acc2Parts = GetParts(theList.Accessory2PartData)
	for _,v in ipairs(acc2Parts) do
		print(v:GetFullName())
	end

	print("Material Parts")

	local materialParts = GetParts(theList.MaterialPartData)
	for _,v in ipairs(materialParts) do
		print(v:GetFullName())
	end
--[[
	local bodyParts = GetParts(weaponTypeDef.BodyParts)

	for _,v in ipairs(bodyParts) do
		print(v:GetFullName())
	end
]]
end

local function ChooseRandom(tbl)
	if #tbl == 0 then
		return nil
	end

	local selectedIndex = math.random(1, #tbl)

	return tbl[selectedIndex]
end

local function CleanupOldInspect(gfx)
	local mesh = ffi.cast("struct UActorComponent*", gfx.MyInspectionMesh)
	print(mesh)
	if mesh ~= nil then
		print(mesh:GetFullName())
		gfx.WPCOwner.Pawn:DetachComponent(mesh)
	end

	--gfx.MyInspectionMesh = nil
end

function InspectRandomWeapon()
	local gfx = engine.FindObjectExactClass("ItemInspectionGFxMovie Transient.ItemInspectionGFxMovie", engine.Classes.UItemInspectionGFxMovie)
	print("Found Inspect movie: " .. gfx:GetFullName())

	print("Generating random weapon data")
	local weaponDefStruct = ffi.new("struct FWeaponDefinitionData")

	local types = GetWeaponTypes()
	local weaponTypeDef = ChooseRandom(types)

	local typeBalanceDefs = GetBalanceDefs(weaponTypeDef)
	local chosenBalance = ChooseRandom(typeBalanceDefs)

	local manufacturers = GetManufacturers(typeBalanceDefs)
	local chosenManu = ChooseRandom(manufacturers)

	local partCollection = chosenBalance:GetInventoryPartListCollection(
		ffi.cast("struct UClass*", engine.Classes.UWeaponPartListCollectionDefinition.static),
		chosenManu,
		11)

	local bodyParts = GetParts(partCollection.BodyPartData)
	local gripParts = GetParts(partCollection.GripPartData)
	local barrelParts = GetParts(partCollection.BarrelPartData)
	local sightParts = GetParts(partCollection.SightPartData)
	local stockParts = GetParts(partCollection.StockPartData)
	local elementalParts = GetParts(partCollection.ElementalPartData)
	local acc1Parts = GetParts(partCollection.Accessory1PartData)
	local acc2Parts = GetParts(partCollection.Accessory2PartData)
	local materialParts = GetParts(partCollection.MaterialPartData)

	weaponDefStruct.WeaponTypeDefinition = weaponTypeDef
	weaponDefStruct.BalanceDefinition = ffi.cast("struct UInventoryBalanceDefinition*", chosenBalance)
	weaponDefStruct.ManufacturerDefinition = chosenManu
	weaponDefStruct.ManufacturerGradeIndex = 11;
	weaponDefStruct.BodyPartDefinition = ChooseRandom(bodyParts)
	weaponDefStruct.GripPartDefinition = ChooseRandom(gripParts)
	weaponDefStruct.BarrelPartDefinition = ChooseRandom(barrelParts)
	weaponDefStruct.SightPartDefinition = ChooseRandom(sightParts)
	weaponDefStruct.StockPartDefinition = ChooseRandom(stockParts)
	weaponDefStruct.ElementalPartDefinition = ChooseRandom(elementalParts)
	weaponDefStruct.Accessory1PartDefinition = ChooseRandom(acc1Parts)
	weaponDefStruct.Accessory2PartDefinition = ChooseRandom(acc2Parts)
	weaponDefStruct.MaterialPartDefinition = ChooseRandom(materialParts)
	weaponDefStruct.PrefixPartDefinition = nil
	weaponDefStruct.TitlePartDefinition = nil
	weaponDefStruct.GameStage = 1
	weaponDefStruct.UniqueId = 0

	print("Cleaning GFX up")
	CleanupOldInspect(gfx)

	print("Getting inv manager")
	local invManager = gfx.WPCOwner:GetPawnInventoryManager()
	print(invManager:GetFullName())

	if lastGenWep then
		print("Removing previous wep from inv")
		invManager:RemoveInventoryFromBackpack(ffi.cast("struct AWillowInventory*", lastGenWep))

		--local destroyed = lastGenWep:Destroy()
		--print(destroyed)
	end

	local newWep = gfx.WPCOwner:Spawn(ffi.cast("struct UClass*", engine.Classes.AWillowWeapon.static))
	newWep = ffi.cast("struct AWillowWeapon*", newWep)
	lastGenWep = newWep

	print("Initializing this weapon")
	newWep:InitializeFromDefinitionData(weaponDefStruct, ffi.cast("struct UObject*", gfx.WPCOwner), true)
	
	print("Calling InspectItem on: " .. newWep:GetFullName())
	gfx:InspectItem(ffi.cast("struct AWillowInventory*", newWep))

	print("Adding item to backpack")
	invManager:AddInventoryToBackpack(ffi.cast("struct AWillowInventory*", newWep))

	--print("Equipping weapon")
	--invManager:SafelySetQuickSlot(ffi.cast("struct AWeapon*", newWep), enum.EQuickWeaponSlot.QuickSelectUp)
end

-- l InspectRandomWeapon()