-- gwen test
include("includes/gwen/gwen.lua")

local ffi = require("ffi")

function TestButton()
	local control = ffi.C.LUAFUNC_CreateNewControl(gwen.Controls.Button)

	controlTest = setmetatable({ control = control }, gwen.meta.Button)
	controlTest:SetText("Now in the JewSex channel")

	controlTest:SetPos(50, 50)
	print(controlTest:GetTypeName())
	controlTest:SetSize(150, 50)

	print(controlTest:GetParent())
	print(controlTest:GetParent():GetTypeName())
end

