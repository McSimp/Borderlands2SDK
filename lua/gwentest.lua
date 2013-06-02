-- gwen test
include("includes/gwen/gwen.lua")

local ffi = require("ffi")

function TestButton()
	local control = ffi.C.LUAFUNC_CreateNewControl(gwen.Controls.Window, nil)

	local windowTest = setmetatable({ control = control }, gwen.meta.WindowControl)
	windowTest:SetTitle("Hello Everynung")
	windowTest:SetPos(50, 50)
	windowTest:SetSize(250, 250)

	local control2 = ffi.C.LUAFUNC_CreateNewControl(gwen.Controls.Button, control)

	local buttonTest = setmetatable({ control = control2 }, gwen.meta.Button)
	buttonTest:SetText("Now in the JewSex channel")
	buttonTest:SetSize(50, 100)
	buttonTest:Dock(8)
	buttonTest:AddOnPress(function(panel) print("Button1 pressed") end)

	local control3 = ffi.C.LUAFUNC_CreateNewControl(gwen.Controls.Button, control)

	local buttonTest = setmetatable({ control = control3 }, gwen.meta.Button)
	buttonTest:SetText("Wilko is a baguette")
	buttonTest:SetSize(50, 100)
	buttonTest:Dock(8)
	buttonTest:AddOnPress(function(panel) print("Button2 pressed") end)

end

