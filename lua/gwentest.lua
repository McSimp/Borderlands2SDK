-- gwen test

local ffi = require("ffi")

ffi.cdef[[
	typedef struct GwenControl GwenControl;
	GwenControl* CreateNewControl(int controlNum);
]]

local GwenControls = {}
GwenControls["Button"] = 0
GwenControls["Window"] = 1;

function TestButton()
	local control = ffi.C.CreateNewControl(GwenControls.Button)
	print(control)
end