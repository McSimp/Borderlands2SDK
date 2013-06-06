local ffi = require("ffi")

ffi.cdef[[
typedef char const * (__thiscall *tGwen_Controls_Base_GetTypeName) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Base_DelayedDelete) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Base_SetParent) (GwenControl*, GwenControl*);
typedef GwenControl* (__thiscall *tGwen_Controls_Base_GetParent) (GwenControl*);
typedef bool (__thiscall *tGwen_Controls_Base_IsChild) (GwenControl*, GwenControl*);
typedef unsigned int (__thiscall *tGwen_Controls_Base_NumChildren) (GwenControl*);
typedef GwenControl* (__thiscall *tGwen_Controls_Base_GetChild) (GwenControl*, unsigned int);
typedef bool (__thiscall *tGwen_Controls_Base_SizeToChildren) (GwenControl*, bool, bool);
typedef GwenPoint (__thiscall *tGwen_Controls_Base_ChildrenSize) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Base_RemoveAllChildren) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Base_SendToBack) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Base_BringToFront) (GwenControl*);
typedef GwenPoint (__thiscall *tGwen_Controls_Base_LocalPosToCanvas) (GwenControl*, GwenPoint const &);
typedef GwenPoint (__thiscall *tGwen_Controls_Base_CanvasPosToLocal) (GwenControl*, GwenPoint const &);
typedef void (__thiscall *tGwen_Controls_Base_Dock) (GwenControl*, int);
typedef int (__thiscall *tGwen_Controls_Base_GetDock) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Base_RestrictToParent) (GwenControl*, bool);
typedef bool (__thiscall *tGwen_Controls_Base_ShouldRestrictToParent) (GwenControl*);
typedef int (__thiscall *tGwen_Controls_Base_X) (GwenControl*);
typedef int (__thiscall *tGwen_Controls_Base_Y) (GwenControl*);
typedef int (__thiscall *tGwen_Controls_Base_Width) (GwenControl*);
typedef int (__thiscall *tGwen_Controls_Base_Height) (GwenControl*);
typedef int (__thiscall *tGwen_Controls_Base_Bottom) (GwenControl*);
typedef int (__thiscall *tGwen_Controls_Base_Right) (GwenControl*);
typedef GwenMargin const & (__thiscall *tGwen_Controls_Base_GetMargin) (GwenControl*);
typedef GwenMargin const & (__thiscall *tGwen_Controls_Base_GetPadding) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Base_SetPos) (GwenControl*, int, int);
typedef GwenPoint (__thiscall *tGwen_Controls_Base_GetPos) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Base_SetWidth) (GwenControl*, int);
typedef void (__thiscall *tGwen_Controls_Base_SetHeight) (GwenControl*, int);
typedef bool (__thiscall *tGwen_Controls_Base_SetSize) (GwenControl*, int, int);
typedef GwenPoint (__thiscall *tGwen_Controls_Base_GetSize) (GwenControl*);
typedef bool (__thiscall *tGwen_Controls_Base_SetBounds) (GwenControl*, int, int, int, int);
typedef void (__thiscall *tGwen_Controls_Base_SetPadding) (GwenControl*, GwenMargin const &);
typedef void (__thiscall *tGwen_Controls_Base_SetMargin) (GwenControl*, GwenMargin const &);
typedef void (__thiscall *tGwen_Controls_Base_MoveTo) (GwenControl*, int, int);
typedef void (__thiscall *tGwen_Controls_Base_MoveBy) (GwenControl*, int, int);
typedef GwenRect const & (__thiscall *tGwen_Controls_Base_GetBounds) (GwenControl*);
typedef GwenControl* (__thiscall *tGwen_Controls_Base_GetControlAt) (GwenControl*, int, int, bool);
typedef GwenRect const & (__thiscall *tGwen_Controls_Base_GetInnerBounds) (GwenControl*);
typedef GwenRect const & (__thiscall *tGwen_Controls_Base_GetRenderBounds) (GwenControl*);
typedef bool (__thiscall *tGwen_Controls_Base_ShouldClip) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Base_SetHidden) (GwenControl*, bool);
typedef bool (__thiscall *tGwen_Controls_Base_Hidden) (GwenControl*);
typedef bool (__thiscall *tGwen_Controls_Base_Visible) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Base_Hide) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Base_Show) (GwenControl*);
typedef bool (__thiscall *tGwen_Controls_Base_ShouldDrawBackground) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Base_SetShouldDrawBackground) (GwenControl*, bool);
typedef void (__thiscall *tGwen_Controls_Base_SetMouseInputEnabled) (GwenControl*, bool);
typedef bool (__thiscall *tGwen_Controls_Base_GetMouseInputEnabled) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Base_SetKeyboardInputEnabled) (GwenControl*, bool);
typedef bool (__thiscall *tGwen_Controls_Base_GetKeyboardInputEnabled) (GwenControl*);
typedef bool (__thiscall *tGwen_Controls_Base_NeedsInputChars) (GwenControl*);
typedef bool (__thiscall *tGwen_Controls_Base_IsHovered) (GwenControl*);
typedef bool (__thiscall *tGwen_Controls_Base_ShouldDrawHover) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Base_Touch) (GwenControl*);
typedef bool (__thiscall *tGwen_Controls_Base_IsOnTop) (GwenControl*);
typedef bool (__thiscall *tGwen_Controls_Base_HasFocus) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Base_Focus) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Base_Blur) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Base_SetIsDisabled) (GwenControl*, bool);
typedef bool (__thiscall *tGwen_Controls_Base_IsDisabled) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Base_Redraw) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Base_SetCacheToTexture) (GwenControl*);
typedef bool (__thiscall *tGwen_Controls_Base_ShouldCacheToTexture) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Base_SetCursor) (GwenControl*, unsigned char);
typedef GwenPoint (__thiscall *tGwen_Controls_Base_GetMinimumSize) (GwenControl*);
typedef GwenPoint (__thiscall *tGwen_Controls_Base_GetMaximumSize) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Base_SetToolTip) (GwenControl*, GwenControl*);
typedef void (__thiscall *tGwen_Controls_Base_SetToolTipTO) (GwenControl*, TextObject const &);
typedef GwenControl* (__thiscall *tGwen_Controls_Base_GetToolTip) (GwenControl*);
typedef bool (__thiscall *tGwen_Controls_Base_IsMenuComponent) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Base_CloseMenus) (GwenControl*);
typedef bool (__thiscall *tGwen_Controls_Base_IsTabable) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Base_SetTabable) (GwenControl*, bool);
typedef void (__thiscall *tGwen_Controls_Base_Invalidate) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Base_InvalidateChildren) (GwenControl*, bool);
typedef void (__thiscall *tGwen_Controls_Base_Position) (GwenControl*, int, int, int);

typedef char const * (__thiscall *tGwen_Controls_Base_GetBaseTypeName) (GwenControl*);
]]

local Base = {}
Base.__index = Base

function Base:_GetInternalControl()
	return self.control
end

function Base:GetTypeName()
	local func = gwen.GetVFunc(self.control, 1, "tGwen_Controls_Base_GetTypeName")
	return ffi.string(func(self.control))
end

function Base:DelayedDelete()
	local func = gwen.GetVFunc(self.control, 2, "tGwen_Controls_Base_DelayedDelete")
	func(self.control)
end

function Base:SetParent(parent)
	local func = gwen.GetVFunc(self.control, 4, "tGwen_Controls_Base_SetParent")
	func(self.control, rawget(parent, control))
end

function Base:GetParent()
	local func = gwen.GetVFunc(self.control, 5, "tGwen_Controls_Base_GetParent")
	local ret = func(self.control)

	return gwen.ControlFromPointer(ret)
end

function Base:IsChild(testControl)
	local func = gwen.GetVFunc(self.control, 8, "tGwen_Controls_Base_IsChild")
	return func(self.control, rawget(testControl, control))
end

function Base:NumChildren()
	local func = gwen.GetVFunc(self.control, 9, "tGwen_Controls_Base_NumChildren")
	return func(self.control)
end

function Base:GetChild(childNum)
	local func = gwen.GetVFunc(self.control, 10, "tGwen_Controls_Base_GetChild")
	local ret = func(self.control, childNum)

	return gwen.ControlFromPointer(ret)
end

function Base:SizeToChildren(w, h)
	local func = gwen.GetVFunc(self.control, 11, "tGwen_Controls_Base_SizeToChildren")
	return func(self.control, w, h)
end

function Base:ChildrenSize()
	local func = gwen.GetVFunc(self.control, 12, "tGwen_Controls_Base_ChildrenSize")
	local ret = func(self.control)
	return ret.x, ret.y
end

function Base:RemoveAllChildren()
	local func = gwen.GetVFunc(self.control, 21, "tGwen_Controls_Base_RemoveAllChildren")
	func(self.control)
end

function Base:SendToBack()
	local func = gwen.GetVFunc(self.control, 22, "tGwen_Controls_Base_SendToBack")
	func(self.control)
end

function Base:BringToFront()
	local func = gwen.GetVFunc(self.control, 23, "tGwen_Controls_Base_BringToFront")
	func(self.control)
end

function Base:LocalPosToCanvas(x, y)
	local func = gwen.GetVFunc(self.control, 25, "tGwen_Controls_Base_LocalPosToCanvas")
	local pointStruct = ffi.new("GwenPoint", x, y)
	local ret = func(self.control, pointStruct)
	return ret.x, ret.y
end

function Base:CanvasPosToLocal(x, y)
	local func = gwen.GetVFunc(self.control, 26, "tGwen_Controls_Base_CanvasPosToLocal")
	local pointStruct = ffi.new("GwenPoint", x, y)
	local ret = func(self.control, pointStruct)
	return ret.x, ret.y
end

function Base:Dock(dock)
	local func = gwen.GetVFunc(self.control, 27, "tGwen_Controls_Base_Dock")
	func(self.control, dock)
end

function Base:GetDock()
	local func = gwen.GetVFunc(self.control, 28, "tGwen_Controls_Base_GetDock")
	return func(self.control)
end

function Base:RestrictToParent(restrict)
	local func = gwen.GetVFunc(self.control, 29, "tGwen_Controls_Base_RestrictToParent")
	func(self.control, restrict)
end

function Base:ShouldRestrictToParent()
	local func = gwen.GetVFunc(self.control, 30, "tGwen_Controls_Base_ShouldRestrictToParent")
	return func(self.control)
end

function Base:X()
	local func = gwen.GetVFunc(self.control, 31, "tGwen_Controls_Base_X")
	return func(self.control)
end

function Base:Y()
	local func = gwen.GetVFunc(self.control, 32, "tGwen_Controls_Base_Y")
	return func(self.control)
end

function Base:Width()
	local func = gwen.GetVFunc(self.control, 33, "tGwen_Controls_Base_Width")
	return func(self.control)
end

function Base:Height()
	local func = gwen.GetVFunc(self.control, 34, "tGwen_Controls_Base_Height")
	return func(self.control)
end

function Base:Bottom()
	local func = gwen.GetVFunc(self.control, 35, "tGwen_Controls_Base_Bottom")
	return func(self.control)
end

function Base:Right()
	local func = gwen.GetVFunc(self.control, 36, "tGwen_Controls_Base_Right")
	return func(self.control)
end

function Base:GetMargin()
	local func = gwen.GetVFunc(self.control, 37, "tGwen_Controls_Base_GetMargin")
	local ret = func(self.control)
	return ret.top, ret.bottom, ret.left, ret.right
end

function Base:GetPadding()
	local func = gwen.GetVFunc(self.control, 38, "tGwen_Controls_Base_GetPadding")
	local ret = func(self.control)
	return ret.top, ret.bottom, ret.left, ret.right
end

function Base:SetPos(x ,y)
	local func = gwen.GetVFunc(self.control, 40, "tGwen_Controls_Base_SetPos")
	func(self.control, x, y)
end

function Base:GetPos()
	local func = gwen.GetVFunc(self.control, 41, "tGwen_Controls_Base_GetPos")
	local ret = func(self.control)
	return ret.x, ret.y
end

function Base:SetWidth(width)
	local func = gwen.GetVFunc(self.control, 42, "tGwen_Controls_Base_SetWidth")
	func(self.control, width)
end

function Base:SetWidth(height)
	local func = gwen.GetVFunc(self.control, 43, "tGwen_Controls_Base_SetHeight")
	func(self.control, height)
end

function Base:SetSize(width, height)
	local func = gwen.GetVFunc(self.control, 45, "tGwen_Controls_Base_SetSize")
	return func(self.control, width, height)
end

function Base:GetSize()
	local func = gwen.GetVFunc(self.control, 46, "tGwen_Controls_Base_GetSize")
	local ret = func(self.control)
	return ret.x, ret.y
end

function Base:SetBounds(x, y, w, h)
	local func = gwen.GetVFunc(self.control, 48, "tGwen_Controls_Base_SetBounds")
	return func(self.control, x, y, w, h)
end

function Base:SetPadding(top, bottom, left, right)
	local func = gwen.GetVFunc(self.control, 49, "tGwen_Controls_Base_SetPadding")
	local margin = ffi.new("GwenMargin", top, bottom, left, right)
	func(self.control, margin)
end

function Base:SetMargin(top, bottom, left, right)
	local func = gwen.GetVFunc(self.control, 50, "tGwen_Controls_Base_SetMargin")
	local margin = ffi.new("GwenMargin", top, bottom, left, right)
	func(self.control, margin)
end

function Base:MoveTo(x, y)
	local func = gwen.GetVFunc(self.control, 51, "tGwen_Controls_Base_MoveTo")
	func(self.control, x, y)
end

function Base:MoveBy(x, y)
	local func = gwen.GetVFunc(self.control, 52, "tGwen_Controls_Base_MoveBy")
	func(self.control, x, y)
end

function Base:GetBounds()
	local func = gwen.GetVFunc(self.control, 53, "tGwen_Controls_Base_GetBounds")
	local ret = func(self.control)
	return ret.x, ret.y, ret.w, ret.h
end

function Base:GetControlAt(x, y, onlyIfMouseEnabled)
	if onlyIfMouseEnabled == nil then onlyIfMouseEnabled = true end

	local func = gwen.GetVFunc(self.control, 54, "tGwen_Controls_Base_GetControlAt")
	local ret = func(self.control, x, y, onlyIfMouseEnabled)

	return gwen.ControlFromPointer(ret)
end

function Base:GetInnerBounds()
	local func = gwen.GetVFunc(self.control, 58, "tGwen_Controls_Base_GetInnerBounds")
	local ret = func(self.control)
	return ret.x, ret.y, ret.w, ret.h
end

function Base:GetRenderBounds()
	local func = gwen.GetVFunc(self.control, 59, "tGwen_Controls_Base_GetRenderBounds")
	local ret = func(self.control)
	return ret.x, ret.y, ret.w, ret.h
end

function Base:ShouldClip()
	local func = gwen.GetVFunc(self.control, 64, "tGwen_Controls_Base_ShouldClip")
	return func(self.control)
end

function Base:SetHidden(hidden)
	local func = gwen.GetVFunc(self.control, 69, "tGwen_Controls_Base_SetHidden")
	func(self.control, hidden)
end

function Base:Hidden()
	local func = gwen.GetVFunc(self.control, 70, "tGwen_Controls_Base_Hidden")
	return func(self.control)
end

function Base:Visible()
	local func = gwen.GetVFunc(self.control, 71, "tGwen_Controls_Base_Visible")
	return func(self.control)
end

function Base:Hide()
	local func = gwen.GetVFunc(self.control, 72, "tGwen_Controls_Base_Hide")
	func(self.control)
end

function Base:Show()
	local func = gwen.GetVFunc(self.control, 73, "tGwen_Controls_Base_Show")
	func(self.control)
end

function Base:ShouldDrawBackground()
	local func = gwen.GetVFunc(self.control, 76, "tGwen_Controls_Base_ShouldDrawBackground")
	return func(self.control)
end

function Base:SetShouldDrawBackground(draw)
	local func = gwen.GetVFunc(self.control, 77, "tGwen_Controls_Base_SetShouldDrawBackground")
	func(self.control, draw)
end

function Base:SetMouseInputEnabled(mouseInput)
	local func = gwen.GetVFunc(self.control, 87, "tGwen_Controls_Base_SetMouseInputEnabled")
	func(self.control, mouseInput)
end

function Base:GetMouseInputEnabled()
	local func = gwen.GetVFunc(self.control, 88, "tGwen_Controls_Base_GetMouseInputEnabled")
	return func(self.control)
end

function Base:SetKeyboardInputEnabled(keyboardInput)
	local func = gwen.GetVFunc(self.control, 89, "tGwen_Controls_Base_SetKeyboardInputEnabled")
	func(self.control, keyboardInput)
end

function Base:GetKeyboardInputEnabled()
	local func = gwen.GetVFunc(self.control, 90, "tGwen_Controls_Base_GetKeyboardInputEnabled")
	return func(self.control)
end

function Base:NeedsInputChars()
	local func = gwen.GetVFunc(self.control, 91, "tGwen_Controls_Base_NeedsInputChars")
	return func(self.control)
end

function Base:IsHovered()
	local func = gwen.GetVFunc(self.control, 113, "tGwen_Controls_Base_IsHovered")
	return func(self.control)
end

function Base:ShouldDrawHover()
	local func = gwen.GetVFunc(self.control, 114, "tGwen_Controls_Base_ShouldDrawHover")
	return func(self.control)
end

function Base:Touch()
	local func = gwen.GetVFunc(self.control, 115, "tGwen_Controls_Base_Touch")
	func(self.control)
end

function Base:IsOnTop()
	local func = gwen.GetVFunc(self.control, 117, "tGwen_Controls_Base_IsOnTop")
	return func(self.control)
end

function Base:HasFocus()
	local func = gwen.GetVFunc(self.control, 118, "tGwen_Controls_Base_HasFocus")
	return func(self.control)
end

function Base:Focus()
	local func = gwen.GetVFunc(self.control, 119, "tGwen_Controls_Base_Focus")
	func(self.control)
end

function Base:Blur()
	local func = gwen.GetVFunc(self.control, 120, "tGwen_Controls_Base_Blur")
	func(self.control)
end

function Base:SetIsDisabled(disabled)
	local func = gwen.GetVFunc(self.control, 121, "tGwen_Controls_Base_SetIsDisabled")
	func(self.control, disabled)
end

function Base:IsDisabled()
	local func = gwen.GetVFunc(self.control, 122, "tGwen_Controls_Base_IsDisabled")
	return func(self.control)
end

function Base:Redraw()
	local func = gwen.GetVFunc(self.control, 123, "tGwen_Controls_Base_Redraw")
	func(self.control)
end

function Base:SetCacheToTexture()
	local func = gwen.GetVFunc(self.control, 125, "tGwen_Controls_Base_SetCacheToTexture")
	func(self.control)
end

function Base:ShouldCacheToTexture()
	local func = gwen.GetVFunc(self.control, 126, "tGwen_Controls_Base_ShouldCacheToTexture")
	return func(self.control)
end

-- TODO: CURSOR ENUM
function Base:SetCursor(cursor)
	local func = gwen.GetVFunc(self.control, 127, "tGwen_Controls_Base_SetCursor")
	func(self.control, cursor)
end

function Base:GetMinimumSize()
	local func = gwen.GetVFunc(self.control, 129, "tGwen_Controls_Base_GetMinimumSize")
	local ret = func(self.control)
	return ret.x, ret.y
end

function Base:GetMaximumSize()
	local func = gwen.GetVFunc(self.control, 130, "tGwen_Controls_Base_GetMaximumSize")
	local ret = func(self.control)
	return ret.x, ret.y
end

function Base:SetToolTipFromControl(tipControl)
	local func = gwen.GetVFunc(self.control, 131, "tGwen_Controls_Base_SetToolTip")
	func(self.control, tipControl)
end

function Base:SetToolTip(text)
	local func = gwen.GetVFunc(self.control, 132, "tGwen_Controls_Base_SetToolTipTO")
	local obj = gwen.GetTextObject(text)
	func(self.control, obj)
	gwen.FreeTextObject(obj)
end

function Base:GetToolTip()
	local func = gwen.GetVFunc(self.control, 133, "tGwen_Controls_Base_GetToolTip")
	local ret = func(self.control)

	return gwen.ControlFromPointer(ret)
end

function Base:IsMenuComponent()
	local func = gwen.GetVFunc(self.control, 134, "tGwen_Controls_Base_IsMenuComponent")
	return func(self.control)
end

function Base:CloseMenus()
	local func = gwen.GetVFunc(self.control, 135, "tGwen_Controls_Base_CloseMenus")
	func(self.control)
end

function Base:IsTabable()
	local func = gwen.GetVFunc(self.control, 136, "tGwen_Controls_Base_IsTabable")
	return func(self.control)
end

function Base:SetTabable(tabable)
	local func = gwen.GetVFunc(self.control, 137, "tGwen_Controls_Base_SetTabable")
	func(self.control, tabable)
end

function Base:Invalidate()
	local func = gwen.GetVFunc(self.control, 142, "tGwen_Controls_Base_Invalidate")
	func(self.control)
end

function Base:InvalidateChildren(bRecursive)
	if bRecursive == nil then bRecursive = false end
	local func = gwen.GetVFunc(self.control, 143, "tGwen_Controls_Base_InvalidateChildren")
	func(self.control, bRecursive)
end

function Base:Position(pos, xpadding, ypadding)
	if xpadding == nil then xpadding = 0 end
	if ypadding == nil then ypadding = 0 end

	local func = gwen.GetVFunc(self.control, 144, "tGwen_Controls_Base_Position")
	func(self.control, pos, xpadding, ypadding)
end

function Base:AlignBelow(belowControl, border)
	if border == nil then border = 0 end
	self:SetPos(self:X(), belowControl:Bottom() + border)
end

function Base:AddOnHoverEnter(func)
	gwen.AddCallback(self.control, 44, "OnHoverEnter", func)
end

function Base:AddOnHoverLeave(func)
	gwen.AddCallback(self.control, 56, "OnHoverLeave", func)
end

gwen.meta.Base = Base

local InheritedControl = table.copy(Base)
InheritedControl.__index = InheritedControl

function InheritedControl:GetBaseTypeName()
	local func = gwen.GetVFunc(self.control, 171, "tGwen_Controls_Base_GetBaseTypeName")
	return ffi.string(func(self.control))
end

gwen.meta.InheritedControl = InheritedControl

--[[
VMT dump from IDA
0: public: virtual void * __thiscall Gwen::Controls::Base::`scalar deleting destructor'(unsigned int)
1: public: virtual char const * __thiscall Gwen::Controls::Base::GetTypeName(void)
2: public: virtual void __thiscall Gwen::Controls::Base::DelayedDelete(void)
#3: public: virtual void __thiscall Gwen::Controls::Base::PreDelete(class Gwen::Skin::Base *)
4: public: virtual void __thiscall Gwen::Controls::Base::SetParent(class Gwen::Controls::Base *)
5: public: virtual class Gwen::Controls::Base * __thiscall Gwen::Controls::Base::GetParent(void)const
#6: public: virtual class Gwen::Controls::Canvas * __thiscall Gwen::Controls::Base::GetCanvas(void)
#7: public: virtual class std::list<class Gwen::Controls::Base *, class std::allocator<class Gwen::Controls::Base *>> & __thiscall Gwen::Controls::Base::GetChildren(void)
8: public: virtual bool __thiscall Gwen::Controls::Base::IsChild(class Gwen::Controls::Base *)
9: public: virtual unsigned int __thiscall Gwen::Controls::Base::NumChildren(void)
10: public: virtual class Gwen::Controls::Base * __thiscall Gwen::Controls::Base::GetChild(unsigned int)
11: public: virtual bool __thiscall Gwen::Controls::Base::SizeToChildren(bool, bool)
12: public: virtual struct Gwen::Point __thiscall Gwen::Controls::Base::ChildrenSize(void)
#13: public: virtual class Gwen::Controls::Base * __thiscall Gwen::Controls::Base::FindChildByName(class std::basic_string<char, struct std::char_traits<char>, class std::allocator<char>> const &, bool)
#14: public: virtual void __thiscall Gwen::Controls::Base::SetName(class std::basic_string<char, struct std::char_traits<char>, class std::allocator<char>> const &)
#15: public: virtual class std::basic_string<char, struct std::char_traits<char>, class std::allocator<char>> const & __thiscall Gwen::Controls::Base::GetName(void)
#16: public: virtual void __thiscall Gwen::Controls::Base::Think(void)
#17: protected: virtual void __thiscall Gwen::Controls::Base::AddChild(class Gwen::Controls::Base *)
#18: protected: virtual void __thiscall Gwen::Controls::Base::RemoveChild(class Gwen::Controls::Base *)
#19: protected: virtual void __thiscall Gwen::Controls::Base::OnChildAdded(class Gwen::Controls::Base *)
#20: protected: virtual void __thiscall Gwen::Controls::Base::OnChildRemoved(class Gwen::Controls::Base *)
21: public: virtual void __thiscall Gwen::Controls::Base::RemoveAllChildren(void)
22: public: virtual void __thiscall Gwen::Controls::Base::SendToBack(void)
23: public: virtual void __thiscall Gwen::Controls::Base::BringToFront(void)
#24: public: virtual void __thiscall Gwen::Controls::Base::BringNextToControl(class Gwen::Controls::Base *, bool)
25: public: virtual struct Gwen::Point __thiscall Gwen::Controls::Base::LocalPosToCanvas(struct Gwen::Point const &)
26: public: virtual struct Gwen::Point __thiscall Gwen::Controls::Base::CanvasPosToLocal(struct Gwen::Point const &)
27: public: virtual void __thiscall Gwen::Controls::Base::Dock(int)
28: public: virtual int __thiscall Gwen::Controls::Base::GetDock(void)
29: public: virtual void __thiscall Gwen::Controls::Base::RestrictToParent(bool)
30: public: virtual bool __thiscall Gwen::Controls::Base::ShouldRestrictToParent(void)
31: public: virtual int __thiscall Gwen::Controls::Base::X(void)const
32: public: virtual int __thiscall Gwen::Controls::Base::Y(void)const
33: public: virtual int __thiscall Gwen::Controls::Base::Width(void)const
34: public: virtual int __thiscall Gwen::Controls::Base::Height(void)const
35: public: virtual int __thiscall Gwen::Controls::Base::Bottom(void)const
36: public: virtual int __thiscall Gwen::Controls::Base::Right(void)const
37: public: virtual struct Gwen::Margin const & __thiscall Gwen::Controls::Base::GetMargin(void)const
38: public: virtual struct Gwen::Margin const & __thiscall Gwen::Controls::Base::GetPadding(void)const
#39: public: virtual void __thiscall Gwen::Controls::Base::SetPos(struct Gwen::Point const &)
40: public: virtual void __thiscall Gwen::Controls::Base::SetPos(int, int)
41: public: virtual struct Gwen::Point __thiscall Gwen::Controls::Base::GetPos(void)
42: public: virtual void __thiscall Gwen::Controls::Base::SetWidth(int)
43: public: virtual void __thiscall Gwen::Controls::Base::SetHeight(int)
#44: public: virtual bool __thiscall Gwen::Controls::Base::SetSize(struct Gwen::Point const &)
45: public: virtual bool __thiscall Gwen::Controls::Base::SetSize(int, int)
46: public: virtual struct Gwen::Point __thiscall Gwen::Controls::Base::GetSize(void)
#47: public: virtual bool __thiscall Gwen::Controls::Base::SetBounds(struct Gwen::Rect const &)
48: public: virtual bool __thiscall Gwen::Controls::Base::SetBounds(int, int, int, int)
49: public: virtual void __thiscall Gwen::Controls::Base::SetPadding(struct Gwen::Margin const &)
50: public: virtual void __thiscall Gwen::Controls::Base::SetMargin(struct Gwen::Margin const &)
51: public: virtual void __thiscall Gwen::Controls::Base::MoveTo(int, int)
52: public: virtual void __thiscall Gwen::Controls::Base::MoveBy(int, int)
53: public: virtual struct Gwen::Rect const & __thiscall Gwen::Controls::Base::GetBounds(void)const
54: public: virtual class Gwen::Controls::Base * __thiscall Gwen::Controls::Base::GetControlAt(int, int, bool)
#55: public: virtual void __thiscall Gwen::Controls::Base::OnBoundsChanged(struct Gwen::Rect)
#56: protected: virtual void __thiscall Gwen::Controls::Base::OnChildBoundsChanged(struct Gwen::Rect, class Gwen::Controls::Base *)
#57: protected: virtual void __thiscall Gwen::Controls::Base::OnScaleChanged(void)
58: public: virtual struct Gwen::Rect const & __thiscall Gwen::Controls::Base::GetInnerBounds(void)const
59: public: virtual struct Gwen::Rect const & __thiscall Gwen::Controls::Base::GetRenderBounds(void)const
#60: protected: virtual void __thiscall Gwen::Controls::Base::UpdateRenderBounds(void)
#61: public: virtual void __thiscall Gwen::Controls::Base::DoRender(class Gwen::Skin::Base *)
#62: public: virtual void __thiscall Gwen::Controls::Base::DoCacheRender(class Gwen::Skin::Base *, class Gwen::Controls::Base *)
#63: public: virtual void __thiscall Gwen::Controls::Base::RenderRecursive(class Gwen::Skin::Base *, struct Gwen::Rect const &)
64: public: virtual bool __thiscall Gwen::Controls::Base::ShouldClip(void)
#65: public: virtual void __thiscall Gwen::Controls::Base::Render(class Gwen::Skin::Base *)
#66: protected: virtual void __thiscall Gwen::Controls::Base::RenderUnder(class Gwen::Skin::Base *)
#67: protected: virtual void __thiscall Gwen::Controls::Base::RenderOver(class Gwen::Skin::Base *)
#68: protected: virtual void __thiscall Gwen::Controls::Base::RenderFocus(class Gwen::Skin::Base *)
69: public: virtual void __thiscall Gwen::Controls::Base::SetHidden(bool)
70: public: virtual bool __thiscall Gwen::Controls::Base::Hidden(void)const
71: public: virtual bool __thiscall Gwen::Controls::Base::Visible(void)const
72: public: virtual void __thiscall Gwen::Controls::Base::Hide(void)
73: public: virtual void __thiscall Gwen::Controls::Base::Show(void)
#74: public: virtual void __thiscall Gwen::Controls::Base::SetSkin(class Gwen::Skin::Base *, bool)
#75: public: virtual class Gwen::Skin::Base * __thiscall Gwen::Controls::Base::GetSkin(void)
76: public: virtual bool __thiscall Gwen::Controls::Base::ShouldDrawBackground(void)
77: public: virtual void __thiscall Gwen::Controls::Base::SetShouldDrawBackground(bool)
#78: protected: virtual void __thiscall Gwen::Controls::Base::OnSkinChanged(class Gwen::Skin::Base *)
#79: public: virtual void __thiscall Gwen::Controls::Base::OnMouseMoved(int, int, int, int)
#80: public: virtual bool __thiscall Gwen::Controls::Base::OnMouseWheeled(int)
#81: public: virtual void __thiscall Gwen::Controls::Base::OnMouseClickLeft(int, int, bool)
#82: public: virtual void __thiscall Gwen::Controls::Base::OnMouseClickRight(int, int, bool)
#83: public: virtual void __thiscall Gwen::Controls::Base::OnMouseDoubleClickLeft(int, int)
#84: public: virtual void __thiscall Gwen::Controls::Base::OnMouseDoubleClickRight(int, int)
#85: public: virtual void __thiscall Gwen::Controls::Base::OnLostKeyboardFocus(void)
#86: public: virtual void __thiscall Gwen::Controls::Base::OnKeyboardFocus(void)
87: public: virtual void __thiscall Gwen::Controls::Base::SetMouseInputEnabled(bool)
88: public: virtual bool __thiscall Gwen::Controls::Base::GetMouseInputEnabled(void)
89: public: virtual void __thiscall Gwen::Controls::Base::SetKeyboardInputEnabled(bool)
90: public: virtual bool __thiscall Gwen::Controls::Base::GetKeyboardInputEnabled(void)const
91: public: virtual bool __thiscall Gwen::Controls::Base::NeedsInputChars(void)
#92: public: virtual bool __thiscall Gwen::Controls::Base::OnChar(wchar_t)
#93: public: virtual bool __thiscall Gwen::Controls::Base::OnKeyPress(int, bool)
#94: public: virtual bool __thiscall Gwen::Controls::Base::OnKeyRelease(int)
#95: public: virtual void __thiscall Gwen::Controls::Base::OnPaste(class Gwen::Controls::Base *)
#96: public: virtual void __thiscall Gwen::Controls::Base::OnCopy(class Gwen::Controls::Base *)
#97: public: virtual void __thiscall Gwen::Controls::Base::OnCut(class Gwen::Controls::Base *)
#98: public: virtual void __thiscall Gwen::Controls::Base::OnSelectAll(class Gwen::Controls::Base *)
#99: public: virtual bool __thiscall Gwen::Controls::Base::OnKeyTab(bool)
#100: public: virtual bool __thiscall Gwen::Controls::Base::OnKeySpace(bool)
#101: public: virtual bool __thiscall Gwen::Controls::Base::OnKeyReturn(bool)
#102: public: virtual bool __thiscall Gwen::Controls::Base::OnKeyBackspace(bool)
#103: public: virtual bool __thiscall Gwen::Controls::Base::OnKeyDelete(bool)
#104: public: virtual bool __thiscall Gwen::Controls::Base::OnKeyRight(bool)
#105: public: virtual bool __thiscall Gwen::Controls::Base::OnKeyLeft(bool)
#106: public: virtual bool __thiscall Gwen::Controls::Base::OnKeyHome(bool)
#107: public: virtual bool __thiscall Gwen::Controls::Base::OnKeyEnd(bool)
#108: public: virtual bool __thiscall Gwen::Controls::Base::OnKeyUp(bool)
#109: public: virtual bool __thiscall Gwen::Controls::Base::OnKeyDown(bool)
#110: public: virtual bool __thiscall Gwen::Controls::Base::OnKeyEscape(bool)
#111: public: virtual void __thiscall Gwen::Controls::Base::OnMouseEnter(void)
#112: public: virtual void __thiscall Gwen::Controls::Base::OnMouseLeave(void)
113: public: virtual bool __thiscall Gwen::Controls::Base::IsHovered(void)
114: public: virtual bool __thiscall Gwen::Controls::Base::ShouldDrawHover(void)
115: public: virtual void __thiscall Gwen::Controls::Base::Touch(void)
#116: public: virtual void __thiscall Gwen::Controls::Base::OnChildTouched(class Gwen::Controls::Base *)
117: public: virtual bool __thiscall Gwen::Controls::Base::IsOnTop(void)
118: public: virtual bool __thiscall Gwen::Controls::Base::HasFocus(void)
119: public: virtual void __thiscall Gwen::Controls::Base::Focus(void)
120: public: virtual void __thiscall Gwen::Controls::Base::Blur(void)
121: public: virtual void __thiscall Gwen::Controls::Base::SetDisabled(bool)
122: public: virtual bool __thiscall Gwen::Controls::Base::IsDisabled(void)
123: public: virtual void __thiscall Gwen::Controls::Base::Redraw(void)
#124: public: virtual void __thiscall Gwen::Controls::Base::UpdateColours(void)
125: public: virtual void __thiscall Gwen::Controls::Base::SetCacheToTexture(void)
126: public: virtual bool __thiscall Gwen::Controls::Base::ShouldCacheToTexture(void)
127: public: virtual void __thiscall Gwen::Controls::Base::SetCursor(unsigned char)
#128: public: virtual void __thiscall Gwen::Controls::Base::UpdateCursor(void)
129: public: virtual struct Gwen::Point __thiscall Gwen::Controls::Base::GetMinimumSize(void)
130: public: virtual struct Gwen::Point __thiscall Gwen::Controls::Base::GetMaximumSize(void)
131: public: virtual void __thiscall Gwen::Controls::Base::SetToolTip(class Gwen::Controls::Base *)
132: public: virtual void __thiscall Gwen::Controls::Base::SetToolTip(class Gwen::TextObject const &)
133: public: virtual class Gwen::Controls::Base * __thiscall Gwen::Controls::Base::GetToolTip(void)
134: public: virtual bool __thiscall Gwen::Controls::Base::IsMenuComponent(void)
135: public: virtual void __thiscall Gwen::Controls::Base::CloseMenus(void)
136: public: virtual bool __thiscall Gwen::Controls::Base::IsTabable(void)
137: public: virtual void __thiscall Gwen::Controls::Base::SetTabable(bool)
#138: public: virtual void __thiscall Gwen::Controls::Base::AcceleratePressed(void)
#139: public: virtual bool __thiscall Gwen::Controls::Base::AccelOnlyFocus(void)
#140: public: virtual bool __thiscall Gwen::Controls::Base::HandleAccelerator(class std::basic_string<wchar_t, struct std::char_traits<wchar_t>, class std::allocator<wchar_t>> &)
#141: protected: virtual class Gwen::Controls::Base * __thiscall Gwen::Controls::Base::Inner(void)
142: public: virtual void __thiscall Gwen::Controls::Base::Invalidate(void)
143: public: virtual void __thiscall Gwen::Controls::Base::InvalidateChildren(bool)
144: public: virtual void __thiscall Gwen::Controls::Base::Position(int, int, int)
#145: protected: virtual void __thiscall Gwen::Controls::Base::RecurseLayout(class Gwen::Skin::Base *)
#146: protected: virtual void __thiscall Gwen::Controls::Base::Layout(class Gwen::Skin::Base *)
#147: public: virtual void __thiscall Gwen::Controls::Base::PostLayout(class Gwen::Skin::Base *)
#148: public: virtual void __thiscall Gwen::Controls::Base::DragAndDrop_SetPackage(bool, class std::basic_string<char, struct std::char_traits<char>, class std::allocator<char>> const &, void *)
#149: public: virtual bool __thiscall Gwen::Controls::Base::DragAndDrop_Draggable(void)
#150: public: virtual bool __thiscall Gwen::Controls::Base::DragAndDrop_ShouldStartDrag(void)
#151: public: virtual void __thiscall Gwen::Controls::Base::DragAndDrop_StartDragging(struct Gwen::DragAndDrop::Package *, int, int)
#152: public: virtual struct Gwen::DragAndDrop::Package * __thiscall Gwen::Controls::Base::DragAndDrop_GetPackage(int, int)
#153: public: virtual void __thiscall Gwen::Controls::Base::DragAndDrop_EndDragging(bool, int, int)
#154: public: virtual void __thiscall Gwen::Controls::Base::DragAndDrop_HoverEnter(struct Gwen::DragAndDrop::Package *, int, int)
#155: public: virtual void __thiscall Gwen::Controls::Base::DragAndDrop_HoverLeave(struct Gwen::DragAndDrop::Package *)
#156: public: virtual void __thiscall Gwen::Controls::Base::DragAndDrop_Hover(struct Gwen::DragAndDrop::Package *, int, int)
#157: public: virtual bool __thiscall Gwen::Controls::Base::DragAndDrop_HandleDrop(struct Gwen::DragAndDrop::Package *, int, int)
#158: public: virtual bool __thiscall Gwen::Controls::Base::DragAndDrop_CanAcceptPackage(struct Gwen::DragAndDrop::Package *)
#159: public: virtual void __thiscall Gwen::Controls::Base::Anim_WidthIn(float, float, float)
#160: public: virtual void __thiscall Gwen::Controls::Base::Anim_HeightIn(float, float, float)
#161: public: virtual void __thiscall Gwen::Controls::Base::Anim_WidthOut(float, bool, float, float)
#162: public: virtual void __thiscall Gwen::Controls::Base::Anim_HeightOut(float, bool, float, float)
#163: public: virtual class Gwen::Controls::Base * __thiscall Gwen::Controls::Base::DynamicCast(char const *)
#164: public: virtual class Gwen::TextObject __thiscall Gwen::Controls::Base::GetChildValue(class std::basic_string<char, struct std::char_traits<char>, class std::allocator<char>> const &)
#165: public: virtual class Gwen::TextObject __thiscall Gwen::Controls::Base::GetValue(void)
#166: public: virtual void __thiscall Gwen::Controls::Base::SetValue(class Gwen::TextObject const &)
#167: public: virtual void __thiscall Gwen::Controls::Base::DoAction(void)
#168: public: virtual void __thiscall Gwen::Controls::Base::SetAction(class Gwen::Event::Handler *, void (__thiscall Gwen::Event::Handler::*)(struct Gwen::Event::Information const &), struct Gwen::Event::Packet const &)
#169: public: virtual class Gwen::ControlList __thiscall Gwen::Controls::Base::GetNamedChildren(class std::basic_string<char, struct std::char_traits<char>, class std::allocator<char>> const &, bool)
#170: public: virtual int __thiscall Gwen::Controls::Base::GetNamedChildren(class Gwen::ControlList &, class std::basic_string<char, struct std::char_traits<char>, class std::allocator<char>> const &, bool)
]]