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
local pcall = pcall

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
		print(string.format("[Lua] Warning: engineHook.ProcessHooks called for %s (0x%X) with no hook table",
			pFunction:GetName(),
			ptrNum))
		return true
	end

	local args = engine._FuncsInternal[ptrNum].args

	local argData = {}
	for i=1,#args do
		argData[args[i].name] = GetArg(args[i], pParms)
	end

	for _,v in pairs(hookTable) do
		local hookFunc = v[1]
		local isRaw = v[2]

		local status, ret
		if not isRaw then
			status, ret = pcall(hookFunc, pObject, argData)
		else
			status, ret = pcall(hookFunc, pObject, pFunction, pParms, pResult)
		end

		if not status then
			print("Error in EngineHook: " .. ret)
		end
	end

	return true
end

function SafeProcessHooks(pObject, pFunction, pParms, pResult)
	local status, ret = pcall(ProcessHooks, pObject, pFunction, pParms, pResult)
	print(status, ret)

	return true
end

local EngineCallback = ffi.cast("tProcessEventHook", ProcessHooks)

local function AddInternal(funcData, hookName, hookFunc, rawHook)
	if type(funcData) ~= "table" then error("Function must be a function data table") end
	if not funcData.ptr or funcData.ptr == nil then error("Function has no pointer") end
	if type(hookName) ~= "string" then error("Hook name must be a string") end
	if type(hookFunc) ~= "function" then error("Hook function must be a function") end

	local ptrNum = PtrToNum(funcData.ptr)
	if RegisteredHooks[ptrNum] == nil then
		RegisteredHooks[ptrNum] = {}
		ffi.C.LUAFUNC_AddStaticEngineHook(funcData.ptr, EngineCallback)
	end

	RegisteredHooks[ptrNum][hookName] = { hookFunc, rawHook }

	print(string.format("[Lua] Engine Hook added for function at 0x%X", ptrNum))
end

function Add(funcData, hookName, hookFunc)
	return AddInternal(funcData, hookName, hookFunc, false)
end

function AddRaw(funcData, hookName, hookFunc)
	return AddInternal(funcData, hookName, hookFunc, true)
end

function RemoveAll()
	-- Foreach function
	for ptrNum,_ in pairs(RegisteredHooks) do
		-- Remove the hook inside the engine
		local ptr = ffi.cast("struct UFunction*", ptrNum)
		ffi.C.LUAFUNC_RemoveStaticEngineHook(ptr)

		-- nil it
		RegisteredHooks[ptrNum] = nil
	end
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