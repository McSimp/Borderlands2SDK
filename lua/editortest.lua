local ffi = require("ffi")

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

	-- Remove default
	table.remove(weaponTypes, 1)

	return weaponTypes
end

local function GetAllBalanceDefs()
	local balanceDefs = {}

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

local weaponEditor = {}
weaponEditor.Types = GetWeaponTypes()
weaponEditor.AllBalanceDefs = GetAllBalanceDefs()

function weaponEditor.GetDefsForType(wepType)
	local allTypes = weaponEditor.Types
	local thisDefs = {}

	for _,v in ipairs(allTypes) do
		if v.WeaponType == wepType then
			table.insert(thisDefs, v)
		end
	end

	return thisDefs
end

function weaponEditor.GetBalanceDefsForTypeDef(wepType)
	local allDefs = weaponEditor.AllBalanceDefs
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
				break
			end

			baseDef = baseDef.BaseDefinition
		end

		::continue::
	end

	return thisTypeDefs
end

function weaponEditor.GetManufacturers(balanceDefs)
	-- For all the balance defs, insert all the elements of the Manufacturers
	-- array into a table
	local manufacturers = {}

	for _,v in ipairs(balanceDefs) do
		if v.Manufacturers.Count ~= 0 then
			for _,mf in ipairs(v.Manufacturers) do
				if not table.contains(manufacturers, mf.Manufacturer) then
					table.insert(manufacturers, mf.Manufacturer)
				end
			end
		end
	end

	return manufacturers
end

function weaponEditor.GetParts(partList)
	local ret = {}
	local parts = partList.WeightedParts

	for _,v in ipairs(parts) do
		table.insert(ret, v.Part)
	end

	return ret
end

function weaponEditor.ClearAndNone(box, event)
	if event == nil then event = false end

	box:ClearItems()
	local item = box:AddItem("None")
	box:SelectItem(item, event)
end

function weaponEditor.SetBoxToEmpty(box)
	weaponEditor.ClearAndNone(box, true)
	box:SetIsDisabled(true)
end

function weaponEditor.PopulateBox(box, members)
	weaponEditor.ClearAndNone(box)
	box:SetIsDisabled(false)

	for k,v in ipairs(members) do
		local menuItem = box:AddItem(v:GetName())
		menuItem.value = v
	end
end

function weaponEditor.MakeLabelBox(parent, name)
	local lbl = gwen.CreateControl("Label", parent)
	lbl:SetText(name)
	lbl:SizeToContents()
	lbl:SetMargin(5, 5, 5, 5)
	lbl:Dock(POS_TOP)

	local box = gwen.CreateControl("ComboBox", parent)
	box:Dock(POS_TOP)

	return lbl, box
end

function weaponEditor.CleanupInspector(gfx)
	local mesh = ffi.cast("struct UActorComponent*", gfx.MyInspectionMesh)
	if mesh ~= nil then
		gfx.WPCOwner.Pawn:DetachComponent(mesh)
	end

	--gfx.MyInspectionMesh = nil
end

function weaponEditor.GetInspector()
	-- ItemInspectionGFxMovie Transient.ItemInspectionGFxMovie_0
	local gfx = engine.FindObjectExactClass("ItemInspectionGFxMovie Transient.ItemInspectionGFxMovie", engine.Classes.UItemInspectionGFxMovie)
	if gfx == nil then error("Could not find inspector") end

	return gfx
end

function EditorTest()
	local window = gwen.CreateControl("WindowControl")
	window:SetTitle("Weapon Editor")
	window:SetPos(gwen.ScrW() - 310, 10)
	window:SetSize(300, gwen.ScrH() - 20)

	local typeLabel, typeBox = weaponEditor.MakeLabelBox(window, "Type")
	local typeDefLabel, typeDefBox = weaponEditor.MakeLabelBox(window, "Type Definition")
	local balanceLabel, balanceBox = weaponEditor.MakeLabelBox(window, "Balance")
	local manuLabel, manuBox = weaponEditor.MakeLabelBox(window, "Manufacturer")

	local bodyLabel, bodyBox = weaponEditor.MakeLabelBox(window, "Body")
	local gripLabel, gripBox = weaponEditor.MakeLabelBox(window, "Grip")
	local barrelLabel, barrelBox = weaponEditor.MakeLabelBox(window, "Barrel")
	local sightLabel, sightBox = weaponEditor.MakeLabelBox(window, "Sight")
	local stockLabel, stockBox = weaponEditor.MakeLabelBox(window, "Stock")
	local elemLabel, elemBox = weaponEditor.MakeLabelBox(window, "Elemental")
	local acc1Label, acc1Box = weaponEditor.MakeLabelBox(window, "Accessory 1")
	local acc2Label, acc2Box = weaponEditor.MakeLabelBox(window, "Accessory 2")
	local matLabel, matBox = weaponEditor.MakeLabelBox(window, "Material")

	local inspectButton = gwen.CreateControl("Button", window)
	inspectButton:SetText("Inspect Weapon")
	inspectButton:SetMargin(10, 5, 5, 5)
	inspectButton:SetSize(50, 40)
	inspectButton:Dock(POS_TOP)
	
	typeBox.OnSelection = function(panel)
		print("typeBox")
		local selected = panel:GetSelectedItem()

		if selected.value == nil then 
			weaponEditor.SetBoxToEmpty(typeDefBox)
			return
		end

		-- Populate the Type Definition box
		local defs = weaponEditor.GetDefsForType(selected.value)
		weaponEditor.PopulateBox(typeDefBox, defs)
	end

	typeDefBox.OnSelection = function(panel)
		print("typeDefBox")
		local selected = panel:GetSelectedItem()

		if selected.value == nil then 
			weaponEditor.SetBoxToEmpty(balanceBox)
			return
		end

		-- Populate the balance box
		local balanceDefs = weaponEditor.GetBalanceDefsForTypeDef(selected.value)
		weaponEditor.PopulateBox(balanceBox, balanceDefs)
	end

	balanceBox.OnSelection = function(panel)
		print("balanceBox")
		local selected = panel:GetSelectedItem()

		if selected.value == nil then 
			weaponEditor.SetBoxToEmpty(manuBox)
			return
		end

		local typeDef = typeDefBox:GetSelectedItem().value
		if typeDef == nil then error("Selected balance without type definition") end

		local balanceDefs = weaponEditor.GetBalanceDefsForTypeDef(typeDef)
		local manus = weaponEditor.GetManufacturers(balanceDefs)
		weaponEditor.PopulateBox(manuBox, manus)
	end

	manuBox.OnSelection = function(panel)
		print("manuBox")
		local selected = panel:GetSelectedItem()

		if selected.value == nil then 
			weaponEditor.SetBoxToEmpty(bodyBox)
			weaponEditor.SetBoxToEmpty(gripBox)
			weaponEditor.SetBoxToEmpty(barrelBox)
			weaponEditor.SetBoxToEmpty(sightBox)
			weaponEditor.SetBoxToEmpty(stockBox)
			weaponEditor.SetBoxToEmpty(elemBox)
			weaponEditor.SetBoxToEmpty(acc1Box)
			weaponEditor.SetBoxToEmpty(acc2Box)
			weaponEditor.SetBoxToEmpty(matBox)
			return
		end

		local balanceDef = balanceBox:GetSelectedItem().value
		if balanceDef == nil then error("Selected manufacturer without balance") end
		
		local partsList = balanceDef:GetInventoryPartListCollection(
			engine.Classes.UWeaponPartListCollectionDefinition,
			selected.value,
			39)

		weaponEditor.PopulateBox(bodyBox, weaponEditor.GetParts(partsList.BodyPartData))
		weaponEditor.PopulateBox(gripBox, weaponEditor.GetParts(partsList.GripPartData))
		weaponEditor.PopulateBox(barrelBox, weaponEditor.GetParts(partsList.BarrelPartData))
		weaponEditor.PopulateBox(sightBox, weaponEditor.GetParts(partsList.SightPartData))
		weaponEditor.PopulateBox(stockBox, weaponEditor.GetParts(partsList.StockPartData))
		weaponEditor.PopulateBox(elemBox, weaponEditor.GetParts(partsList.ElementalPartData))
		weaponEditor.PopulateBox(acc1Box, weaponEditor.GetParts(partsList.Accessory1PartData))
		weaponEditor.PopulateBox(acc2Box, weaponEditor.GetParts(partsList.Accessory2PartData))
		weaponEditor.PopulateBox(matBox, weaponEditor.GetParts(partsList.MaterialPartData))
	end

	inspectButton.OnPress = function(panel)
		print("button")
		print("Creating weapon definition")
		local weaponDefStruct = ffi.new("struct FWeaponDefinitionData")

		weaponDefStruct.WeaponTypeDefinition = typeDefBox:GetSelectedItem().value
		weaponDefStruct.BalanceDefinition = ffi.cast("struct UInventoryBalanceDefinition*", balanceBox:GetSelectedItem().value)
		weaponDefStruct.ManufacturerDefinition = manuBox:GetSelectedItem().value
		weaponDefStruct.ManufacturerGradeIndex = 39;
		weaponDefStruct.BodyPartDefinition = bodyBox:GetSelectedItem().value
		weaponDefStruct.GripPartDefinition = gripBox:GetSelectedItem().value
		weaponDefStruct.BarrelPartDefinition = barrelBox:GetSelectedItem().value
		weaponDefStruct.SightPartDefinition = sightBox:GetSelectedItem().value
		weaponDefStruct.StockPartDefinition = stockBox:GetSelectedItem().value
		weaponDefStruct.ElementalPartDefinition = elemBox:GetSelectedItem().value
		weaponDefStruct.Accessory1PartDefinition = acc1Box:GetSelectedItem().value
		weaponDefStruct.Accessory2PartDefinition = acc2Box:GetSelectedItem().value
		weaponDefStruct.MaterialPartDefinition = matBox:GetSelectedItem().value
		weaponDefStruct.PrefixPartDefinition = nil
		weaponDefStruct.TitlePartDefinition = nil
		weaponDefStruct.GameStage = 1
		weaponDefStruct.UniqueId = 0

		print("Getting inspector")
		local inspector = weaponEditor.GetInspector()

		print("Cleaning up inspector")
		weaponEditor.CleanupInspector(inspector)

		print("Creating new weapon actor")
		local newWep = inspector.WPCOwner:Spawn(engine.Classes.AWillowWeapon)
		newWep = ffi.cast("struct AWillowWeapon*", newWep)

		if newWep == nil then error("newWep was nil") end

		print("Initializing the weapon")
		newWep:InitializeFromDefinitionData(weaponDefStruct,inspector.WPCOwner, true)

		print("Calling InspectItem on: " .. newWep:GetFullName())
		inspector:InspectItem(newWep)
	end

	-- Populate the weapon type box
	weaponEditor.ClearAndNone(typeBox)
	for k,v in pairs(enums.EWeaponType) do
		if k ~= "WT_MAX" then
			typeBox:AddItem(k).value = v
		end
	end
end
