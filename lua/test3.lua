local ffi = require("ffi")
local bit = require("bit")

scriptHook.Remove(engine.Classes.UCustomizationDefinition.funcs.GetAvailableCustomizationsForPlayer, "LolDev")
scriptHook.Add(engine.Classes.UCustomizationDefinition.funcs.GetAvailableCustomizationsForPlayer, "LolDev", function(Object, Stack, Result, Function)
	print("GetAvailableCustomizationsForPlayer called")

	local originalCode = Stack.Code
	print(originalCode)
	local out = ""

	while true do
		local opcode = Stack.Code[0]
		out = out .. bit.tohex(opcode, 2) .. " "
		if opcode == 0x16 then break end
		Stack.Code = Stack.Code + 1
	end

	print(out)

	Stack.Code = originalCode
	print(Stack.Code)

	local PC = Stack:GetObject("struct AWillowPlayerController*")
	Stack:GetTArray()
	Stack:GetTArray()
	Stack:GetInt()
	local RequiredType = Stack:GetObject("struct UObject*")
	local bDebugAllowLocked = Stack:GetBool()
	local CharacterClassOverride = Stack:GetObject("struct UWillowCharacterClassDefinition*")

	print(PC, RequiredType, bDebugAllowLocked, CharacterClassOverride)
	print(PC:GetFullName())
	print(RequiredType:GetFullName())
	

	Stack.Code = originalCode
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

--[[
args = {
			{
				name = "PC",
				cdata = true,
				type = ffi.typeof("struct AWillowPlayerController*"),
				castTo = ffi.typeof("struct AWillowPlayerController**"),
				offset = 0
			},
			{
				name = "RequiredType",
				optional = true,
				cdata = true,
				type = ffi.typeof("struct UObject*"),
				castTo = ffi.typeof("struct UObject**"),
				offset = 32
			},
			{
				name = "bDebugAllowLocked",
				optional = true,
				type = "boolean",
				castTo = ffi.typeof("bool*"),
				offset = 36
			},
			{
				name = "CharacterClassOverride",
				optional = true,
				cdata = true,
				type = ffi.typeof("struct UWillowCharacterClassDefinition*"),
				castTo = ffi.typeof("struct UWillowCharacterClassDefinition**"),
				offset = 40
			},
		},
		retvals = {
			{
				name = "AvailableCustomizations",
				cType = ffi.typeof("struct TArray_UCustomizationDefinitionPtr_"),
				castTo = ffi.typeof("struct TArray_UCustomizationDefinitionPtr_*"),
				offset = 4
			},
			{
				name = "AvailableCustomizationsBeenSeen",
				cType = ffi.typeof("struct TArray_int_"),
				castTo = ffi.typeof("struct TArray_int_*"),
				offset = 16
			},
			{
				name = "LockedCustomizationCount",
				castTo = ffi.typeof("int*"),
				offset = 28
			},
		},
]]
