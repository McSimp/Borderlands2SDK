local ffi = require("ffi")

ffi.cdef[[
typedef void (__thiscall *tGwen_Controls_Label_SetText) (GwenControl*, TextObject const &, bool);
typedef TextObject const & (__thiscall *tGwen_Controls_Label_GetText) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Label_SizeToContents) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Label_SetAlignment) (GwenControl*, int);
typedef int (__thiscall *tGwen_Controls_Label_GetAlignment) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Label_SetTextColor) (GwenControl*, GwenColor const &);
typedef void (__thiscall *tGwen_Controls_Label_SetTextColorOverride) (GwenControl*, GwenColor const &);
typedef int (__thiscall *tGwen_Controls_Label_TextWidth) (GwenControl*);
typedef int (__thiscall *tGwen_Controls_Label_TextRight) (GwenControl*);
typedef int (__thiscall *tGwen_Controls_Label_TextHeight) (GwenControl*);
typedef int (__thiscall *tGwen_Controls_Label_TextX) (GwenControl*);
typedef int (__thiscall *tGwen_Controls_Label_TextY) (GwenControl*);
typedef int (__thiscall *tGwen_Controls_Label_TextLength) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Label_SetTextPadding) (GwenControl*, GwenMargin const &);
typedef GwenMargin const & (__thiscall *tGwen_Controls_Label_GetTextPadding) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Label_MakeColorNormal) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Label_MakeColorBright) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Label_MakeColorDark) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Label_MakeColorHighlight) (GwenControl*);
typedef bool (__thiscall *tGwen_Controls_Label_Wrap) (GwenControl*);
typedef void (__thiscall *tGwen_Controls_Label_SetWrap) (GwenControl*, bool);
]]

local Label = table.copy(gwen.meta.InheritedControl)
Label.__index = Label

function Label:SetText(text, doEvents)
	if doEvents == nil then doEvents = true end

	local func = gwen.GetVFunc(self.control, 169, "tGwen_Controls_Label_SetText")
	local obj = gwen.GetTextObject(text)
	func(self.control, obj, doEvents)
	gwen.FreeTextObject(obj)
end

function Label:GetText()
	local func = gwen.GetVFunc(self.control, 170, "tGwen_Controls_Label_GetText")
	return gwen.GetStringFromTextObject(func(self.control))
end

function Label:SizeToContents()
	local func = gwen.GetVFunc(self.control, 171, "tGwen_Controls_Label_SizeToContents")
	func(self.control)
end

function Label:SetAlignment(alignment)
	local func = gwen.GetVFunc(self.control, 172, "tGwen_Controls_Label_SetAlignment")
	func(self.control, alignment)
end

function Label:GetAlignment()
	local func = gwen.GetVFunc(self.control, 173, "tGwen_Controls_Label_GetAlignment")
	return func(self.control)
end

function Label:SetTextColor(color)
	local func = gwen.GetVFunc(self.control, 177, "tGwen_Controls_Label_SetTextColor")
	func(self.control, color)
end

function Label:SetTextColorOverride(color)
	local func = gwen.GetVFunc(self.control, 178, "tGwen_Controls_Label_SetTextColorOverride")
	func(self.control, color)
end

function Label:TextWidth()
	local func = gwen.GetVFunc(self.control, 179, "tGwen_Controls_Label_TextWidth")
	return func(self.control)
end

function Label:TextRight()
	local func = gwen.GetVFunc(self.control, 180, "tGwen_Controls_Label_TextRight")
	return func(self.control)
end

function Label:TextHeight()
	local func = gwen.GetVFunc(self.control, 181, "tGwen_Controls_Label_TextHeight")
	return func(self.control)
end

function Label:TextX()
	local func = gwen.GetVFunc(self.control, 182, "tGwen_Controls_Label_TextX")
	return func(self.control)
end

function Label:TextY()
	local func = gwen.GetVFunc(self.control, 183, "tGwen_Controls_Label_TextY")
	return func(self.control)
end

function Label:TextLength()
	local func = gwen.GetVFunc(self.control, 184, "tGwen_Controls_Label_TextLength")
	return func(self.control)
end

function Label:SetTextPadding(top, bottom, left, right)
	local func = gwen.GetVFunc(self.control, 185, "tGwen_Controls_Label_SetTextPadding")
	local margin = ffi.new("GwenMargin", top, bottom, left, right)
	func(self.control, margin)
end

function Label:GetTextPadding()
	local func = gwen.GetVFunc(self.control, 186, "tGwen_Controls_Label_GetTextPadding")
	local ret = func(self.control)
	return ret.top, ret.bottom, ret.left, ret.right
end

function Label:MakeColorNormal()
	local func = gwen.GetVFunc(self.control, 187, "tGwen_Controls_Label_MakeColorNormal")
	func(self.control)
end

function Label:MakeColorBright()
	local func = gwen.GetVFunc(self.control, 188, "tGwen_Controls_Label_MakeColorBright")
	func(self.control)
end

function Label:MakeColorDark()
	local func = gwen.GetVFunc(self.control, 189, "tGwen_Controls_Label_MakeColorDark")
	func(self.control)
end

function Label:MakeColorHighlight()
	local func = gwen.GetVFunc(self.control, 190, "tGwen_Controls_Label_MakeColorHighlight")
	func(self.control)
end

function Label:Wrap()
	local func = gwen.GetVFunc(self.control, 191, "tGwen_Controls_Label_Wrap")
	return func(self.control)
end

function Label:SetWrap(wrap)
	local func = gwen.GetVFunc(self.control, 192, "tGwen_Controls_Label_SetWrap")
	func(self.control, wrap)
end

gwen.meta.Label = Label

--[[
VMT dump from IDA
168: public: virtual char const * __thiscall *tGwen_Controls_Label_GetBaseTypeName(void)
169: public: virtual void __thiscall *tGwen_Controls_Label_SetText(class Gwen::TextObject const &, bool)
170: public: virtual class Gwen::TextObject const & __thiscall *tGwen_Controls_Label_GetText(void)const
171: public: virtual void __thiscall *tGwen_Controls_Label_SizeToContents(void)
172: public: virtual void __thiscall *tGwen_Controls_Label_SetAlignment(int)
173: public: virtual int __thiscall *tGwen_Controls_Label_GetAlignment(void)
#174: public: virtual void __thiscall *tGwen_Controls_Label_SetFont(struct Gwen::Font *)
#175: public: virtual void __thiscall *tGwen_Controls_Label_SetFont(class std::basic_string<wchar_t, struct std::char_traits<wchar_t>, class std::allocator<wchar_t>>, int, bool)
#176: public: virtual struct Gwen::Font * __thiscall *tGwen_Controls_Label_GetFont(void)
177: public: virtual void __thiscall *tGwen_Controls_Label_SetTextColor(struct Gwen::Color const &)
178: public: virtual void __thiscall *tGwen_Controls_Label_SetTextColorOverride(struct Gwen::Color const &)
179: public: virtual int __thiscall *tGwen_Controls_Label_TextWidth(void)
180: public: virtual int __thiscall *tGwen_Controls_Label_TextRight(void)
181: public: virtual int __thiscall *tGwen_Controls_Label_TextHeight(void)
182: public: virtual int __thiscall *tGwen_Controls_Label_TextX(void)
183: public: virtual int __thiscall *tGwen_Controls_Label_TextY(void)
184: public: virtual int __thiscall *tGwen_Controls_Label_TextLength(void)
185: public: virtual void __thiscall *tGwen_Controls_Label_SetTextPadding(struct Gwen::Margin const &)
186: public: virtual struct Gwen::Margin const & __thiscall *tGwen_Controls_Label_GetTextPadding(void)
187: public: virtual void __thiscall *tGwen_Controls_Label_MakeColorNormal(void)
188: public: virtual void __thiscall *tGwen_Controls_Label_MakeColorBright(void)
189: public: virtual void __thiscall *tGwen_Controls_Label_MakeColorDark(void)
190: public: virtual void __thiscall *tGwen_Controls_Label_MakeColorHighlight(void)
191: public: virtual bool __thiscall *tGwen_Controls_Label_Wrap(void)
192: public: virtual void __thiscall *tGwen_Controls_Label_SetWrap(bool)
#193: protected: virtual void __thiscall *tGwen_Controls_Label_OnTextChanged(void)
]]