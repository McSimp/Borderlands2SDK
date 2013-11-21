local ffi = require("ffi")
local bit = require("bit")

ffi.cdef[[
typedef void (__thiscall *tFrameStep) (struct FFrame*, struct UObject*, void*);
]]
local pFrameStep = ffi.cast("tFrameStep", bl2sdk.FrameStep)

local FFrameMT = {}

function FFrameMT.GetFuncCodeHex(self)
	local originalCode = self.Code
	local out = ""

	-- TODO: Limit
	while true do
		local opcode = self.Code[0]
		out = out .. bit.tohex(opcode, 2) .. " "
		if opcode == 0x16 then break end
		self.Code = self.Code + 1
	end

	self.Code = originalCode

	return out
end

function FFrameMT.GetLocalsHex(self, length)
	local out = ""

	for i=1,length do
		out = out .. bit.tohex(self.Locals[i - 1], 2) .. " "
	end

	return out
end

function FFrameMT.ReadType(self, ptrType, size)
	local result = ffi.cast(ptrType, self.Code)[0]
	self.Code = self.Code + size
	return result
end

function FFrameMT.ReadInt(self)
	return self:ReadType(ffi.typeof("int*"), 4)
end

function FFrameMT.ReadFloat(self)
	return self:ReadType(ffi.typeof("float*"), 4)
end

function FFrameMT.ReadName(self)
	return self:ReadType(ffi.typeof("struct FName*"), ffi.sizeof("struct FName"))
end

function FFrameMT.ReadObject(self)
	return self:ReadType(ffi.typeof("struct UObject**"), 8) -- In C++, size = sizeof(ScriptPointerType) = sizeof(QWORD) = 8
end

function FFrameMT.ReadWord(self)
	return self:ReadType(ffi.typeof("unsigned short*"), 2)
end

FFrameMT.Step = pFrameStep

local function GetGenericNumber(Stack)
	local var = ffi.new("int[1]", 0)
	pFrameStep(Stack, Stack.Object, var)
	return var[0]
end

local function GetCastedType(Stack, toCast)
	local var = ffi.new(toCast .. "[1]")
	pFrameStep(Stack, Stack.Object, var)
	return var[0]
end

FFrameMT.GetBool = GetGenericNumber
FFrameMT.GetStruct = GetCastedType
FFrameMT.GetInt = GetGenericNumber
FFrameMT.GetFloat = GetGenericNumber
FFrameMT.GetByte = GetGenericNumber

function FFrameMT.GetName(self)
	return GetCastedType(self, "struct FName")
end

function FFrameMT.GetString(self)
	return GetCastedType(self, "struct FString")
end

-- TODO: TArray inner type
function FFrameMT.GetTArray(self)
	return GetCastedType(self, "struct TArray")
end

FFrameMT.GetObject = GetCastedType -- Have to use a pointer type (like struct UObject*)

function FFrameMT.WriteOpToCode(self, opCode)
	self.Code[0] = opCode -- Code is already an unsigned char*
	self.Code = self.Code + 1
end

function FFrameMT.WriteToCode(self, castTo, size, value)
	ffi.cast(castTo, self.Code)[0] = value
	self.Code = self.Code + size
end

local CopyNatives = {}

-- execLocalVariable
CopyNatives[0x00] = function(Stack, Object, newStack)
	local value = Stack:ReadObject()
	newStack:WriteOpToCode(0x00)
	newStack:WriteToCode("struct UObject**", 8, value)
end

-- execInstanceVariable
CopyNatives[0x01] = function(Stack, Object, newStack)
	local value = Stack:ReadObject()
	newStack:WriteOpToCode(0x01)
	newStack:WriteToCode("struct UObject**", 8, value)
end

-- execObjectConst
CopyNatives[0x20] = function(Stack, Object, newStack)
	local value = Stack:ReadObject()
	newStack:WriteOpToCode(0x20)
	newStack:WriteToCode("struct UObject**", 8, value)
end

-- execLocalVariableOffsetInt
CopyNatives[0x4C] = function(Stack, Object, newStack)
	local value = Stack:ReadInt()
	newStack:WriteOpToCode(0x4C)
	newStack:WriteToCode("int*", 4, value)
end

function FFrameMT.CopyStep(self, newStack)
	local native = CopyNatives[self.Code[0]]
	print("Calling native " .. tostring(self.Code[0]))
	self.Code = self.Code + 1
	native(self, self.Object, newStack)
end

function FFrameMT.PrintStackInfo(self)
	print(string.format("Stack Frame: \n\tbAllowSuppression = %d\n\tbSuppressEventTag = %d\n\tbAutoEmitLineTerminator = %d\n\tNode = 0x%X\n\tObject = 0x%X\n\tCode = 0x%X\n\tLocals = 0x%X\n\tPreviousFrame = 0x%X\n\tOutParms = 0x%X", 
		self.bAllowSuppression,
		self.bSuppressEventTag,
		self.bAutoEmitLineTerminator,
		PtrToNum(self.Node),
		PtrToNum(self.Object),
		PtrToNum(self.Code),
		PtrToNum(self.Locals),
		PtrToNum(self.PreviousFrame),
		PtrToNum(self.OutParms)
	))
end

function FFrameMT.SkipFunction(self)
	-- TODO: Limit
	while true do
		local opcode = self.Code[0]
		self.Code = self.Code + 1
		if opcode == 0x16 then break end
	end
end

ffi.metatype("struct FFrame", { __index = FFrameMT })

module("FFrame")

function NewStack(oldStack)
	local stack = ffi.new("struct FFrame")
	local buffer = ffi.new("unsigned char[?]", 128)

	stack.Code = buffer

	stack.VfTable = oldStack.VfTable
	stack.bAllowSuppression = oldStack.bAllowSuppression
	stack.bSuppressEventTag = oldStack.bSuppressEventTag
	stack.bAutoEmitLineTerminator = oldStack.bAutoEmitLineTerminator
	stack.Node = oldStack.Node
	stack.Object = oldStack.Object
	stack.Locals = oldStack.Locals
	stack.PreviousFrame = oldStack.PreviousFrame
	stack.OutParms = oldStack.OutParms

	return stack
end
