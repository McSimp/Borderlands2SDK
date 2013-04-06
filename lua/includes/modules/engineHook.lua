local ffi = require("ffi")
local engine = engine
local PtrToNum = PtrToNum
local table = table
local type = type
local print = print
local error = error
local unpack = unpack
local pairs = pairs
local string = string

ffi.cdef[[
typedef bool (*tProcessEventHook) (struct UObject*, struct UFunction*, char*, void*);
void LUAFUNC_AddStaticEngineHook(struct UFunction* pFunction, tProcessEventHook funcHook);
void LUAFUNC_RemoveStaticEngineHook(struct UFunction* pFunction);
]]

module("engineHook")

RegisteredHooks = {}

local function GetArg(arg, pParms)
	return ffi.cast(arg.castTo, pParms + arg.offset)[0]
end

function ProcessHooks(pObject, pFunction, pParms, pResult)
	local ptrNum = PtrToNum(pFunction)
	local hookTable = RegisteredHooks[ptrNum]

	if hookTable == nil then
		print(string.format("[Lua] Warning: ProcessHooks called for %s (0x%X) with no hook table",
			pFunction:GetName(),
			ptrNum))
		return true
	end

	local args = engine._FuncsInternal[ptrNum].args

	local argData = {}
	for i=1,#args do
		table.insert(argData, GetArg(args[i], pParms))
	end

	for _,v in pairs(hookTable) do
		v(unpack(argData)) -- TODO: Return value
	end

	return true
end

local EngineCallback = ffi.cast("tProcessEventHook", ProcessHooks)

function Add(funcData, hookName, hookFunc)
	if type(funcData) ~= "table" then error("Function must be a function data table") end
	if not funcData.ptr or funcData.ptr == nil then error("Function has no pointer") end
	if type(hookName) ~= "string" then error("Hook name must be a string") end
	if type(hookFunc) ~= "function" then error("Hook function must be a function") end

	local ptrNum = PtrToNum(funcData.ptr)
	if RegisteredHooks[ptrNum] == nil then
		RegisteredHooks[ptrNum] = {}
		ffi.C.LUAFUNC_AddStaticEngineHook(funcData.ptr, EngineCallback)
	end

	RegisteredHooks[ptrNum][hookName] = hookFunc

	print(string.format("[Lua] Engine Hook added for function at 0x%X", ptrNum))
end

function Remove(funcData, hookName)
	if type(funcData) ~= "table" then error("Function must be a function data table") end
	if not funcData.ptr then error("Function has no pointer") end
	if type(hookName) ~= "string" then error("Hook name must be a string") end

	local ptrNum = PtrToNum(funcData.ptr)
	if RegisteredHooks[ptrNum] == nil then print("Hook table for function does not exist") return end

	RegisteredHooks[ptrNum][hookName] = nil
	if table.count(RegisteredHooks[ptrNum]) == 0 then
		ffi.C.LUAFUNC_RemoveStaticEngineHook(funcData.ptr)
		RegisteredHooks[ptrNum] = nil
	end

	print(string.format("[Lua] Engine Hook removed for function at 0x%X", ptrNum))
end