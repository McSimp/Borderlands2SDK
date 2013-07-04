local string = string
local print = print
local ffi = require("ffi")

local LuaCommands = {}

local function CommandHook(Object, Stack, Result, Function)
	local code = Stack.Code
	local cmd = Stack:GetString()
	local cmdString = cmd:GetLuaString()
	local cmdLower = string.lower(cmdString)

	if LuaCommands[cmdLower] ~= nil then
		print("\n>>> " .. cmdString .. " <<<")

		LuaCommands[cmdLower](cmdString)

		local console = ffi.cast("struct UConsole*", Object)

		local cmp
		if console.UConsole.HistoryTop == 0 then
			cmp = console.UConsole.History[15]
		else
			cmp = console.UConsole.History[console.UConsole.HistoryTop - 1]
		end

		if cmp:IsValid() and cmdLower ~= string.lower(cmp:GetLuaString()) then
			console:PurgeCommandFromHistory(cmd)

			console.UConsole.History[console.UConsole.HistoryTop] = cmd
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
