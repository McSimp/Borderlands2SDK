local string = string
local print = print
local ffi = require("ffi")

local LuaCommands = {}

local function ParseCommand(cmdString)
	-- trim string
	cmdString = string.Trim(cmdString)

	-- if length is zero, fail
	if #cmdString == 0 then return nil end

	-- find the first space, and extract string from start to that
	-- otherwise just get the whole string if no space found
	local loc = string.find(cmdString, " ")
	if loc == nil then 
		return cmdString, {} -- no args
	end

	local cmd = string.sub(cmdString, 1, loc - 1)

	-- for the args, we want to extract the part after the first space
	local argString = string.sub(cmdString, loc + 1)
	local argT = string.Explode(argString, " ")

	return cmd, argT
end

local function CommandHook(Object, Stack, Result, Function)
	local code = Stack.Code
	local cmdStringObject = Stack:GetString()
	local fullCmdString = cmdStringObject:GetLuaString()

	local cmd, args = ParseCommand(fullCmdString)
	if not cmd then
		Stack:SkipFunction()
		return true
	end

	local cmdLower = string.lower(cmd)

	if LuaCommands[cmdLower] ~= nil then
		print("\n>>> " .. fullCmdString .. " <<<")

		local status, ret = pcall(LuaCommands[cmdLower], cmd, args)
		if not status then print("Error in command: " .. ret) end

		local console = ffi.cast("struct UConsole*", Object)

		local cmp
		if console.UConsole.HistoryTop == 0 then
			cmp = console.UConsole.History[15]
		else
			cmp = console.UConsole.History[console.UConsole.HistoryTop - 1]
		end

		if cmp:IsValid() and cmdStringObject ~= cmp then
			console:PurgeCommandFromHistory(cmdStringObject)

			console.UConsole.History[console.UConsole.HistoryTop] = cmdStringObject
			console.UConsole.HistoryTop = (console.UConsole.HistoryTop + 1) % 16
		end

		console.UConsole.HistoryCur = console.UConsole.HistoryTop

		Stack:SkipFunction()
		return true
	end

	-- Call ConsoleCommand instead, because ShippingConsoleCommand adds 'say' to the front
	Stack.Code = code
	scriptHook.CallFunction(Object, Stack, Result, engine.Classes.UConsole.funcs.ConsoleCommand.ptr)
	return true
end
scriptHook.AddRaw(engine.Classes.UConsole.funcs.ShippingConsoleCommand, "CommandHook", CommandHook)

module("command")

function GetTable()
	return LuaCommands
end

function Add(name, func)
	local nameLower = string.lower(name)

	if LuaCommands[nameLower] ~= nil then
		print("WARNING: Command '" .. name .. "' already exists, overwriting")
	end

	LuaCommands[nameLower] = func
end

function Remove(name)
	local nameLower = string.lower(name)
	LuaCommands[nameLower] = nil
end
