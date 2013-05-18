-- gwen test
include("includes/gwen/gwen.lua")

local ffi = require("ffi")

ffi.cdef[[
typedef void (__thiscall *tGwen_Controls_Label_SetText) (GwenControl*, TextObject&, bool);
]]

local Button = table.copy(gwen.meta.Base)
Button.__index = Button

function Button:SetPos(x ,y)
	local func = gwen.GetVFunc(self.control, 40, "tGwen_Controls_Base_SetPos")
	func(self.control, x, y)
end

function Button:SetSize(x, y)
	local func = gwen.GetVFunc(self.control, 45, "tGwen_Controls_Base_SetSize")
	func(self.control, x, y)
end

function Button:SetText(str)
	local textObj = ffi.C.LUAFUNC_NewTextObject(str)
	local func = gwen.GetVFunc(self.control, 169, "tGwen_Controls_Label_SetText")
	func(self.control, textObj, true)
	ffi.C.free(textObj)
end

gwen.meta.Button = Button

function TestButton()
	local control = ffi.C.LUAFUNC_CreateNewControl(gwen.Controls.Button)

	controlTest = setmetatable({ control = control }, Button)
	controlTest:SetText("Now in the JewSex channel")

	controlTest:SetPos(50, 50)
	print(controlTest:GetTypeName())
	controlTest:SetSize(150, 50)

	print(controlTest:GetParent())
	print(controlTest:GetParent():GetTypeName())
end

