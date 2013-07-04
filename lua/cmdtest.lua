local ffi = require("ffi")

scriptHook.Remove(engine.Classes.UConsole.funcs.ShippingConsoleCommand, "ConcmdHook")
scriptHook.Add(engine.Classes.UConsole.funcs.ShippingConsoleCommand, "ConcmdHook", function(Object, Stack, Result, Function)
	print("ShippingConsoleCommand called")
	
	--scriptHook.CallFunction(Object, Stack, Result, engine.Classes.UConsole.funcs.ConsoleCommand.ptr)

	--newStack:PrintStackInfo()

	--Stack:SkipFunction()

	--return true
end)