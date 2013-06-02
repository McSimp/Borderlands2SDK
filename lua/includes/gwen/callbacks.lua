local ffi = require("ffi")
local PtrToNum = PtrToNum

ffi.cdef[[
typedef void (__thiscall *EventHandlerFunction)(GwenControl* this, GwenControl* pFromPanel);
void LUAFUNC_AddGwenCallback(GwenControl* control, int offset, EventHandlerFunction callback);
]]

local RegisteredCallbacks = {}
local CallbackFFIFuncs = {}

function gwen.ExecCallbacks(cbTable, this, pFromPanel)
	local ptrNum = PtrToNum(pFromPanel)

	local hookTable = cbTable[ptrNum]

	if hookTable == nil then
		print(string.format("[Lua] Warning: gwen.ExecCallbacks called on 0x%X with no hook table", ptrNum))
		return
	end

	for _,v in ipairs(hookTable) do
		v(pFromPanel)
	end
end

function gwen.AddCallback(control, offset, name, func)
	-- We haven't registered any callbacks for this yet, so we need to make a new
	-- FFI callback function for this particular event.
	if CallbackFFIFuncs[name] == nil then
		local cbFunc = function(this, pFromPanel)
			gwen.ExecCallbacks(RegisteredCallbacks[name], this, pFromPanel)
		end

		RegisteredCallbacks[name] = {}
		-- Creates a callback - needs to be freed manually
		CallbackFFIFuncs[name] = ffi.cast("EventHandlerFunction", cbFunc)

		print(string.format("[Lua] Created new FFI CB for Gwen event: %s", name))
	end

	local ptrNum = PtrToNum(control)
	if RegisteredCallbacks[name][ptrNum] == nil then
		RegisteredCallbacks[name][ptrNum] = {}
		ffi.C.LUAFUNC_AddGwenCallback(control, offset, CallbackFFIFuncs[name])
	end

	table.insert(RegisteredCallbacks[name][ptrNum], func)

	print(string.format("[Lua] Gwen callback added for event: %s", name))
end