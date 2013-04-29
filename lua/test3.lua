local ffi = require("ffi")
local bit = require("bit")

--[[
scriptHook.Remove(engine.Classes.UCustomizationDefinition.funcs.GetAvailableCustomizationsForPlayer, "LolDev")
scriptHook.Add(engine.Classes.UCustomizationDefinition.funcs.GetAvailableCustomizationsForPlayer, "LolDev", function(Object, Stack, Result, Function)
	print("GetAvailableCustomizationsForPlayer called")

	--local a,b = pcall(function(Object, Stack, Result, Function)
		local originalCode = Stack.Code

		print(Stack:GetFuncArgsHex())

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

		Stack:PrintStackInfo()

		local newStack = FFrame.NewStack(Stack)
		local startCode = newStack.Code

		Stack:CopyStep(newStack)
		Stack:CopyStep(newStack)
		Stack:CopyStep(newStack)
		Stack:CopyStep(newStack)
		Stack:CopyStep(newStack)
		newStack:WriteOpToCode(0x27)
		newStack:WriteOpToCode(0x4A)
		newStack:WriteOpToCode(0x16)
		newStack:WriteOpToCode(0x0F)

		newStack.Code = startCode
		Stack.Code = originalCode

		print(newStack:GetFuncArgsHex())

		newStack:PrintStackInfo()

		scriptHook.CallFunction(Object, newStack, Result, Function)

		newStack:PrintStackInfo()

		Stack:SkipFunction()
	--end, Object, Stack, Result, Function)

	--print(a,b)

	return true
end)
]]

scriptHook.Remove(engine.Classes.UCustomizationDefinition.funcs.GetAvailableCustomizationsForPlayer, "LolDev2")
scriptHook.Add(engine.Classes.UCustomizationDefinition.funcs.GetAvailableCustomizationsForPlayer, "LolDev2", function(Object, Stack, Result, Function)
	print("GetAvailableCustomizationsForPlayer called")

	local originalCode = Stack.Code
	print(Stack:GetFuncArgsHex())
	Stack:PrintStackInfo()

	local newStack = FFrame.NewStack(Stack)
	local startCode = newStack.Code

	Stack:CopyStep(newStack)
	Stack:CopyStep(newStack)
	Stack:CopyStep(newStack)
	Stack:CopyStep(newStack)
	Stack:CopyStep(newStack)
	newStack:WriteOpToCode(0x27)
	newStack:WriteOpToCode(0x4A)
	newStack:WriteOpToCode(0x16)

	newStack.Code = startCode
	Stack.Code = originalCode

	print(newStack:GetFuncArgsHex())
	newStack:PrintStackInfo()

	scriptHook.CallFunction(Object, newStack, Result, Function)

	newStack:PrintStackInfo()

	Stack:SkipFunction()

	return true
end)

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
