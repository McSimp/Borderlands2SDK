local ffi = require("ffi")

ffi.cdef[[
typedef void (__thiscall *tGwen_Controls_ComboBox_SelectItem) (GwenControl*, GwenControl*, bool);
//typedef void (__thiscall *tGwen_Controls_ComboBox_SelectItemByName) (GwenControl*, class std::basic_string<char, struct std::char_traits<char>, class std::allocator<char>> const &, bool);
typedef GwenControl* (__thiscall *tGwen_Controls_ComboBox_GetSelectedItem) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_ComboBox_OpenList) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_ComboBox_CloseList) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_ComboBox_ClearItems) (GwenControl*);
//typedef class Gwen::Controls::MenuItem * (__thiscall *tGwen_Controls_ComboBox_AddItem) (GwenControl*, class std::basic_string<wchar_t, struct std::char_traits<wchar_t>, class std::allocator<wchar_t>> const &, class std::basic_string<char, struct std::char_traits<char>, class std::allocator<char>> const &);
typedef bool (__thiscall *tGwen_Controls_ComboBox_IsMenuOpen) (GwenControl*);

GwenControl* LUAFUNC_AddComboItem(GwenControl* control, const char* label, const char* name);
]]

local ComboBox = table.copy(gwen.meta.Button)
ComboBox.__index = ComboBox

function ComboBox:SelectItem(pItem, bFireChangeEvents)
	if not pItem.GetTypeName or pItem:GetTypeName() ~= "MenuItem" then error("Item must be a Gwen MenuItem") end
	if bFireChangeEvents == nil then bFireChangeEvents = true end

	local func = gwen.GetVFunc(self.control, 208, "tGwen_Controls_ComboBox_SelectItem")
	func(self.control, rawget(pItem, "control"), bFireChangeEvents)
end

--[[
function ComboBox:SelectItemByName(var1, var2, var3, var4)
	local func = gwen.GetVFunc(self.control, 209, "tGwen_Controls_ComboBox_SelectItemByName")
	-- FIX ARGS FOR THIS FUNCTION
	func(self.control, var1, var2, var3, var4)
end
]]

function ComboBox:GetSelectedItem()
	local func = gwen.GetVFunc(self.control, 210, "tGwen_Controls_ComboBox_GetSelectedItem")
	local ret = func(self.control)

	return gwen.ControlFromPointer(ret)
end

function ComboBox:OnItemSelected(pControl)
	local func = gwen.GetVFunc(self.control, 211, "tGwen_Controls_ComboBox_OnItemSelected")
	func(self.control, rawget(pControl, "control"))
end

function ComboBox:OpenList()
	local func = gwen.GetVFunc(self.control, 212, "tGwen_Controls_ComboBox_OpenList")
	func(self.control)
end

function ComboBox:CloseList()
	local func = gwen.GetVFunc(self.control, 213, "tGwen_Controls_ComboBox_CloseList")
	func(self.control)
end

function ComboBox:ClearItems()
	local func = gwen.GetVFunc(self.control, 214, "tGwen_Controls_ComboBox_ClearItems")
	func(self.control)
end

function ComboBox:AddItem(label, name)
	if label == nil then error("Label must not be nil") end
	local ret = ffi.C.LUAFUNC_AddComboItem(self.control, label, name)
	return gwen.ControlFromPointer(ret)
end

function ComboBox:IsMenuOpen()
	local func = gwen.GetVFunc(self.control, 216, "tGwen_Controls_ComboBox_IsMenuOpen")
	return func(self.control)
end

if _DEBUG then
	ComboBox.Events.OnSelection = 348
else
	ComboBox.Events.OnSelection = 288
end

gwen.meta.ComboBox = ComboBox

--[[
VMT dump from IDA
208: public: virtual void __thiscall Gwen::Controls::ComboBox::SelectItem(class Gwen::Controls::MenuItem *, bool)
209: public: virtual void __thiscall Gwen::Controls::ComboBox::SelectItemByName(class std::basic_string<char, struct std::char_traits<char>, class std::allocator<char>> const &, bool)
210: public: virtual class Gwen::Controls::Label * __thiscall Gwen::Controls::ComboBox::GetSelectedItem(void)
211: public: virtual void __thiscall Gwen::Controls::ComboBox::OnItemSelected(class Gwen::Controls::Base *)
212: public: virtual void __thiscall Gwen::Controls::ComboBox::OpenList(void)
213: public: virtual void __thiscall Gwen::Controls::ComboBox::CloseList(void)
214: public: virtual void __thiscall Gwen::Controls::ComboBox::ClearItems(void)
#215: public: virtual class Gwen::Controls::MenuItem * __thiscall Gwen::Controls::ComboBox::AddItem(class std::basic_string<wchar_t, struct std::char_traits<wchar_t>, class std::allocator<wchar_t>> const &, class std::basic_string<char, struct std::char_traits<char>, class std::allocator<char>> const &)
216: public: virtual bool __thiscall Gwen::Controls::ComboBox::IsMenuOpen(void)
]]
