local ffi = require("ffi")
local PtrToNum = PtrToNum

ffi.cdef[[
typedef void (__thiscall *EventHandlerFunction)(GwenControl* this, GwenControl* pFromPanel);
typedef void (*tGwenBaseDestructorHook) (GwenControl* control);
void LUAFUNC_AddGwenCallback(GwenControl* control, int offset, EventHandlerFunction callback);
void LUAFUNC_SetDestructorCallback(tGwenBaseDestructorHook callback);
void LUAFUNC_RemoveGwenCallback(GwenControl* control, int offset, EventHandlerFunction callback);
]]

local RegisteredCallbacks = {}
local CallbackFFIFuncs = {}

function gwen.ExecCallbacks(cbTable, this, pFromPanel)
	print("ExecCallbacks called")
	local ptrNum = PtrToNum(pFromPanel)

	local hook = cbTable[ptrNum]

	if hook == nil then
		print(string.format("[Lua] Warning: gwen.ExecCallbacks called on 0x%X with no hook", ptrNum))
		return
	end

	local status, err = pcall(hook, gwen.ControlFromPointer(pFromPanel))
	if not status then
		print("Error in Gwen callback: " .. err)
	end
end

function gwen.SetCallback(control, offset, name, func)
	local ptrNum = PtrToNum(control)

	-- First, if we're setting the CB to nil, we might need to tell gwen we don't want the CB anymore
	if func == nil and RegisteredCallbacks[name] ~= nil and RegisteredCallbacks[name][ptrNum] ~= nil then
		-- Remove CB from gwen
		ffi.C.LUAFUNC_RemoveGwenCallback(control, offset, CallbackFFIFuncs[name])
		RegisteredCallbacks[name][ptrNum] = nil

		-- TODO: Do we want to remove the FFI callback as well?

		print(string.format("[Lua] Gwen callback removed for event: %s", name))
		return
	end

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

	-- If the callback hasn't been set yet, 
	if RegisteredCallbacks[name][ptrNum] == nil then
		ffi.C.LUAFUNC_AddGwenCallback(control, offset, CallbackFFIFuncs[name])
	end

	RegisteredCallbacks[name][ptrNum] = func

	print(string.format("[Lua] Gwen callback added for event: %s", name))
end

local function OnDestructorCalled(control)
	print("Destructor called")
	
	local ptrNum = PtrToNum(control)
	for name,cbTable in pairs(RegisteredCallbacks) do
		if cbTable[ptrNum] ~= nil then
			cbTable[ptrNum] = nil
		end
	end

	gwen._ActiveControls[ptrNum] = nil
end

local destructorCB = ffi.cast("tGwenBaseDestructorHook", OnDestructorCalled)
ffi.C.LUAFUNC_SetDestructorCallback(destructorCB)