local ffi = require("ffi")
local engine = engine
local PtrToNum = PtrToNum
local table = table
local type = type
local print = print
local error = error
local pairs = pairs
local string = string
local bl2sdk = bl2sdk
local pcall = pcall

ffi.cdef[[
typedef bool (*tCallFunctionHook) (struct UObject*, struct FFrame&, void* const Result, struct UFunction*);
void LUAFUNC_AddStaticScriptHook(struct UFunction* pFunction, tCallFunctionHook funcHook);
void LUAFUNC_RemoveStaticScriptHook(struct UFunction* pFunction);
typedef void (__thiscall *tCallFunction) (struct UObject*, struct FFrame*, void* const, struct UFunction*);
]]

module("scriptHook")

CallFunction = ffi.cast("tCallFunction", bl2sdk.CallFunction)

RegisteredHooks = {}

function ProcessHooks(Object, Stack, Result, Function)
	local ptrNum = PtrToNum(Function)
	local hookTable = RegisteredHooks[ptrNum]

	if hookTable == nil then
		print(string.format("[Lua] Warning: scriptHook.ProcessHooks called for %s (0x%X) with no hook table",
			Function:GetName(),
			ptrNum))
		return true
	end

	for _,v in pairs(hookTable) do
		local codePtr = Stack.Code
		--local ret = v(Object, Stack, Result, Function)
		local status, ret = pcall(v, Object, Stack, Result, Function)
		if not status then
			print("Error in ScriptHook: " .. ret)
			ret = false
		end

		-- A non-nil/false value means that we probably created a new stack and executed
		-- the function with it, so we don't want the original call to go through.
		if not ret then
			Stack.Code = codePtr -- Restore the code pointer to what it was originally
		else
			return false
		end
	end

	return true
end

local EngineCallback = ffi.cast("tCallFunctionHook", ProcessHooks)

function Add(funcData, hookName, hookFunc)
	if type(funcData) ~= "table" then error("Function must be a function data table") end
	if not funcData.ptr or funcData.ptr == nil then error("Function has no pointer") end
	if type(hookName) ~= "string" then error("Hook name must be a string") end
	if type(hookFunc) ~= "function" then error("Hook function must be a function") end

	local ptrNum = PtrToNum(funcData.ptr)
	if RegisteredHooks[ptrNum] == nil then
		RegisteredHooks[ptrNum] = {}
		ffi.C.LUAFUNC_AddStaticScriptHook(funcData.ptr, EngineCallback)
	end

	RegisteredHooks[ptrNum][hookName] = hookFunc

	print(string.format("[Lua] UnrealScript Hook added for function at 0x%X", ptrNum))
end

function Remove(funcData, hookName)
	if type(funcData) ~= "table" then error("Function must be a function data table") end
	if not funcData.ptr then error("Function has no pointer") end
	if type(hookName) ~= "string" then error("Hook name must be a string") end

	local ptrNum = PtrToNum(funcData.ptr)
	if RegisteredHooks[ptrNum] == nil then print("Hook table for function does not exist") return end

	RegisteredHooks[ptrNum][hookName] = nil
	if table.count(RegisteredHooks[ptrNum]) == 0 then
		ffi.C.LUAFUNC_RemoveStaticScriptHook(funcData.ptr)
		RegisteredHooks[ptrNum] = nil
	end

	print(string.format("[Lua] UnrealScript Hook removed for function at 0x%X", ptrNum))
end