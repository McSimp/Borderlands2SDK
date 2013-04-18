local ffi = require("ffi")

ffi.cdef[[
typedef bool (*tCallFunctionHook) (struct UObject*, struct FFrame&, void* const Result, struct UFunction*);
void LUAFUNC_AddStaticScriptHook(struct UFunction* pFunction, tCallFunctionHook* funcHook);
void LUAFUNC_RemoveStaticScriptHook(struct UFunction* pFunction);
]]

module("scriptHook")

RegisteredHooks = {}

function ProcessHooks(pObject, Stack, Result, Function)
	local ptrNum = PtrToNum(Function)
	local hookTable = RegisteredHooks[ptrNum]

	if hookTable == nil then
		print(string.format("[Lua] Warning: scriptHook.ProcessHooks called for %s (0x%X) with no hook table",
			Function:GetName(),
			ptrNum))
		return true
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