-- gwen test

local ffi = require("ffi")

ffi.cdef[[

void free(void* _Memory);

typedef struct {
	int* VMT;
} GwenControl;

typedef struct TextObject TextObject;

GwenControl* LUAFUNC_CreateNewControl(int controlNum);
TextObject* LUAFUNC_NewTextObject(const char* str);

]]

ffi.cdef[[
typedef char const * (__thiscall *tGwen_Controls_Base_GetTypeName) ();
typedef void (__thiscall *tGwen_Controls_Base_DelayedDelete) ();
typedef void (__thiscall *tGwen_Controls_Base_SetParent) (GwenControl*);
typedef GwenControl* (__thiscall *tGwen_Controls_Base_GetParent) ();

typedef void (__thiscall *tGwen_Controls_Base_SetPos) (GwenControl*, int, int);
typedef bool (__thiscall *tGwen_Controls_Base_SetSize) (GwenControl*, int, int);
typedef void (__thiscall *tGwen_Controls_Label_SetText) (GwenControl*, TextObject&, bool);
]]

local gwen = {}
gwen.Controls = { Button = 0, Window = 1 }

function gwen.GetVFunc(control, idx, typedef)
	return ffi.cast(typedef, control.VMT[idx])
end

local Base = {}
Base.__index = Base

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
	return func(self.control) 
	-- TODO: Need to use GetTypeName to get the actual type, then pass that
	-- to a setmetatable({ control = retval }, gwen.meta[typeName])
end


local Button = {}
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

function TestButton()
	local control = ffi.C.LUAFUNC_CreateNewControl(gwen.Controls.Button)

	controlTest = setmetatable({ control = control }, Button)
	controlTest:SetPos(250, 50)

	controlTest:SetText("Now in the JewSex channel")

	controlTest:SetSize(150, 50)

	print(controlTest)
end

--[[
0: public: virtual void * __thiscall Gwen::Controls::Button::`scalar deleting destructor'(unsigned int)
1: public: virtual char const * __thiscall Gwen::Controls::Button::GetTypeName(void)
2: public: virtual void __thiscall Gwen::Controls::Base::DelayedDelete(void)
#3: public: virtual void __thiscall Gwen::Controls::Label::PreDelete(class Gwen::Skin::Base *)
4: public: virtual void __thiscall Gwen::Controls::Base::SetParent(class Gwen::Controls::Base *)
5: public: virtual class Gwen::Controls::Base * __thiscall Gwen::Controls::Base::GetParent(void)const


6: public: virtual class Gwen::Controls::Canvas * __thiscall Gwen::Controls::Base::GetCanvas(void)
7: public: virtual class std::list<class Gwen::Controls::Base *, class std::allocator<class Gwen::Controls::Base *>> & __thiscall Gwen::Controls::Base::GetChildren(void)
8: public: virtual bool __thiscall Gwen::Controls::Base::IsChild(class Gwen::Controls::Base *)
9: public: virtual unsigned int __thiscall Gwen::Controls::Base::NumChildren(void)
10: public: virtual class Gwen::Controls::Base * __thiscall Gwen::Controls::Base::GetChild(unsigned int)
11: public: virtual bool __thiscall Gwen::Controls::Base::SizeToChildren(bool, bool)
12: public: virtual struct Gwen::Point __thiscall Gwen::Controls::Base::ChildrenSize(void)
13: public: virtual class Gwen::Controls::Base * __thiscall Gwen::Controls::Base::FindChildByName(class std::basic_string<char, struct std::char_traits<char>, class std::allocator<char>> const &, bool)
14: public: virtual void __thiscall Gwen::Controls::Base::SetName(class std::basic_string<char, struct std::char_traits<char>, class std::allocator<char>> const &)
15: public: virtual class std::basic_string<char, struct std::char_traits<char>, class std::allocator<char>> const & __thiscall Gwen::Controls::Base::GetName(void)
16: public: virtual void __thiscall Gwen::Controls::Base::Think(void)
17: protected: virtual void __thiscall Gwen::Controls::Base::AddChild(class Gwen::Controls::Base *)
18: protected: virtual void __thiscall Gwen::Controls::Base::RemoveChild(class Gwen::Controls::Base *)
19: protected: virtual void __thiscall Gwen::Controls::Base::OnChildAdded(class Gwen::Controls::Base *)
20: protected: virtual void __thiscall Gwen::Controls::Base::OnChildRemoved(class Gwen::Controls::Base *)
21: public: virtual void __thiscall Gwen::Controls::Base::RemoveAllChildren(void)
22: public: virtual void __thiscall Gwen::Controls::Base::SendToBack(void)
23: public: virtual void __thiscall Gwen::Controls::Base::BringToFront(void)
24: public: virtual void __thiscall Gwen::Controls::Base::BringNextToControl(class Gwen::Controls::Base *, bool)
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
39: public: virtual void __thiscall Gwen::Controls::Base::SetPos(struct Gwen::Point const &)
40: public: virtual void __thiscall Gwen::Controls::Base::SetPos(int, int)
41: public: virtual struct Gwen::Point __thiscall Gwen::Controls::Base::GetPos(void)
42: public: virtual void __thiscall Gwen::Controls::Base::SetWidth(int)
43: public: virtual void __thiscall Gwen::Controls::Base::SetHeight(int)
44: public: virtual bool __thiscall Gwen::Controls::Base::SetSize(struct Gwen::Point const &)
45: public: virtual bool __thiscall Gwen::Controls::Base::SetSize(int, int)
46: public: virtual struct Gwen::Point __thiscall Gwen::Controls::Base::GetSize(void)
47: public: virtual bool __thiscall Gwen::Controls::Base::SetBounds(struct Gwen::Rect const &)
48: public: virtual bool __thiscall Gwen::Controls::Base::SetBounds(int, int, int, int)
49: public: virtual void __thiscall Gwen::Controls::Base::SetPadding(struct Gwen::Margin const &)
50: public: virtual void __thiscall Gwen::Controls::Base::SetMargin(struct Gwen::Margin const &)
51: public: virtual void __thiscall Gwen::Controls::Base::MoveTo(int, int)
52: public: virtual void __thiscall Gwen::Controls::Base::MoveBy(int, int)
53: public: virtual struct Gwen::Rect const & __thiscall Gwen::Controls::Base::GetBounds(void)const
54: public: virtual class Gwen::Controls::Base * __thiscall Gwen::Controls::Base::GetControlAt(int, int, bool)
55: public: virtual void __thiscall Gwen::Controls::Label::OnBoundsChanged(struct Gwen::Rect)
56: protected: virtual void __thiscall Gwen::Controls::Base::OnChildBoundsChanged(struct Gwen::Rect, class Gwen::Controls::Base *)
57: protected: virtual void __thiscall Gwen::Controls::Base::OnScaleChanged(void)
58: public: virtual struct Gwen::Rect const & __thiscall Gwen::Controls::Base::GetInnerBounds(void)const
59: public: virtual struct Gwen::Rect const & __thiscall Gwen::Controls::Base::GetRenderBounds(void)const
60: protected: virtual void __thiscall Gwen::Controls::Base::UpdateRenderBounds(void)
61: public: virtual void __thiscall Gwen::Controls::Base::DoRender(class Gwen::Skin::Base *)
62: public: virtual void __thiscall Gwen::Controls::Base::DoCacheRender(class Gwen::Skin::Base *, class Gwen::Controls::Base *)
63: public: virtual void __thiscall Gwen::Controls::Base::RenderRecursive(class Gwen::Skin::Base *, struct Gwen::Rect const &)
64: public: virtual bool __thiscall Gwen::Controls::Base::ShouldClip(void)
65: public: virtual void __thiscall Gwen::Controls::Button::Render(class Gwen::Skin::Base *)
66: protected: virtual void __thiscall Gwen::Controls::Base::RenderUnder(class Gwen::Skin::Base *)
67: protected: virtual void __thiscall Gwen::Controls::Base::RenderOver(class Gwen::Skin::Base *)
68: protected: virtual void __thiscall Gwen::Controls::Base::RenderFocus(class Gwen::Skin::Base *)
69: public: virtual void __thiscall Gwen::Controls::Base::SetHidden(bool)
70: public: virtual bool __thiscall Gwen::Controls::Base::Hidden(void)const
71: public: virtual bool __thiscall Gwen::Controls::Base::Visible(void)const
72: public: virtual void __thiscall Gwen::Controls::Base::Hide(void)
73: public: virtual void __thiscall Gwen::Controls::Base::Show(void)
74: public: virtual void __thiscall Gwen::Controls::Base::SetSkin(class Gwen::Skin::Base *, bool)
75: public: virtual class Gwen::Skin::Base * __thiscall Gwen::Controls::Base::GetSkin(void)
76: public: virtual bool __thiscall Gwen::Controls::Base::ShouldDrawBackground(void)
77: public: virtual void __thiscall Gwen::Controls::Base::SetShouldDrawBackground(bool)
78: protected: virtual void __thiscall Gwen::Controls::Base::OnSkinChanged(class Gwen::Skin::Base *)
79: public: virtual void __thiscall Gwen::Controls::Base::OnMouseMoved(int, int, int, int)
80: public: virtual bool __thiscall Gwen::Controls::Base::OnMouseWheeled(int)
81: public: virtual void __thiscall Gwen::Controls::Button::OnMouseClickLeft(int, int, bool)
82: public: virtual void __thiscall Gwen::Controls::Button::OnMouseClickRight(int, int, bool)
83: public: virtual void __thiscall Gwen::Controls::Button::OnMouseDoubleClickLeft(int, int)
84: public: virtual void __thiscall Gwen::Controls::Base::OnMouseDoubleClickRight(int, int)
85: public: virtual void __thiscall Gwen::Controls::Base::OnLostKeyboardFocus(void)
86: public: virtual void __thiscall Gwen::Controls::Base::OnKeyboardFocus(void)
87: public: virtual void __thiscall Gwen::Controls::Base::SetMouseInputEnabled(bool)
88: public: virtual bool __thiscall Gwen::Controls::Base::GetMouseInputEnabled(void)
89: public: virtual void __thiscall Gwen::Controls::Base::SetKeyboardInputEnabled(bool)
90: public: virtual bool __thiscall Gwen::Controls::Base::GetKeyboardInputEnabled(void)const
91: public: virtual bool __thiscall Gwen::Controls::Base::NeedsInputChars(void)
92: public: virtual bool __thiscall Gwen::Controls::Base::OnChar(wchar_t)
93: public: virtual bool __thiscall Gwen::Controls::Base::OnKeyPress(int, bool)
94: public: virtual bool __thiscall Gwen::Controls::Base::OnKeyRelease(int)
95: public: virtual void __thiscall Gwen::Controls::Base::OnPaste(class Gwen::Controls::Base *)
96: public: virtual void __thiscall Gwen::Controls::Base::OnCopy(class Gwen::Controls::Base *)
97: public: virtual void __thiscall Gwen::Controls::Base::OnCut(class Gwen::Controls::Base *)
98: public: virtual void __thiscall Gwen::Controls::Base::OnSelectAll(class Gwen::Controls::Base *)
99: public: virtual bool __thiscall Gwen::Controls::Base::OnKeyTab(bool)
100: public: virtual bool __thiscall Gwen::Controls::Button::OnKeySpace(bool)
101: public: virtual bool __thiscall Gwen::Controls::Base::OnKeyReturn(bool)
102: public: virtual bool __thiscall Gwen::Controls::Base::OnKeyBackspace(bool)
103: public: virtual bool __thiscall Gwen::Controls::Base::OnKeyDelete(bool)
104: public: virtual bool __thiscall Gwen::Controls::Base::OnKeyRight(bool)
105: public: virtual bool __thiscall Gwen::Controls::Base::OnKeyLeft(bool)
106: public: virtual bool __thiscall Gwen::Controls::Base::OnKeyHome(bool)
107: public: virtual bool __thiscall Gwen::Controls::Base::OnKeyEnd(bool)
108: public: virtual bool __thiscall Gwen::Controls::Base::OnKeyUp(bool)
109: public: virtual bool __thiscall Gwen::Controls::Base::OnKeyDown(bool)
110: public: virtual bool __thiscall Gwen::Controls::Base::OnKeyEscape(bool)
111: public: virtual void __thiscall Gwen::Controls::Base::OnMouseEnter(void)
112: public: virtual void __thiscall Gwen::Controls::Base::OnMouseLeave(void)
113: public: virtual bool __thiscall Gwen::Controls::Base::IsHovered(void)
114: public: virtual bool __thiscall Gwen::Controls::Base::ShouldDrawHover(void)
115: public: virtual void __thiscall Gwen::Controls::Base::Touch(void)
116: public: virtual void __thiscall Gwen::Controls::Base::OnChildTouched(class Gwen::Controls::Base *)
117: public: virtual bool __thiscall Gwen::Controls::Base::IsOnTop(void)
118: public: virtual bool __thiscall Gwen::Controls::Base::HasFocus(void)
119: public: virtual void __thiscall Gwen::Controls::Base::Focus(void)
120: public: virtual void __thiscall Gwen::Controls::Base::Blur(void)
121: public: virtual void __thiscall Gwen::Controls::Base::SetDisabled(bool)
122: public: virtual bool __thiscall Gwen::Controls::Base::IsDisabled(void)
123: public: virtual void __thiscall Gwen::Controls::Base::Redraw(void)
124: public: virtual void __thiscall Gwen::Controls::Button::UpdateColours(void)
125: public: virtual void __thiscall Gwen::Controls::Base::SetCacheToTexture(void)
126: public: virtual bool __thiscall Gwen::Controls::Base::ShouldCacheToTexture(void)
127: public: virtual void __thiscall Gwen::Controls::Base::SetCursor(unsigned char)
128: public: virtual void __thiscall Gwen::Controls::Base::UpdateCursor(void)
129: public: virtual struct Gwen::Point __thiscall Gwen::Controls::Base::GetMinimumSize(void)
130: public: virtual struct Gwen::Point __thiscall Gwen::Controls::Base::GetMaximumSize(void)
131: public: virtual void __thiscall Gwen::Controls::Base::SetToolTip(class Gwen::Controls::Base *)
132: public: virtual void __thiscall Gwen::Controls::Base::SetToolTip(class Gwen::TextObject const &)
133: public: virtual class Gwen::Controls::Base * __thiscall Gwen::Controls::Base::GetToolTip(void)
134: public: virtual bool __thiscall Gwen::Controls::Base::IsMenuComponent(void)
135: public: virtual void __thiscall Gwen::Controls::Base::CloseMenus(void)
136: public: virtual bool __thiscall Gwen::Controls::Base::IsTabable(void)
137: public: virtual void __thiscall Gwen::Controls::Base::SetTabable(bool)
138: public: virtual void __thiscall Gwen::Controls::Button::AcceleratePressed(void)
139: public: virtual bool __thiscall Gwen::Controls::Base::AccelOnlyFocus(void)
140: public: virtual bool __thiscall Gwen::Controls::Base::HandleAccelerator(class std::basic_string<wchar_t, struct std::char_traits<wchar_t>, class std::allocator<wchar_t>> &)
141: protected: virtual class Gwen::Controls::Base * __thiscall Gwen::Controls::Base::Inner(void)
142: protected: virtual void __thiscall Gwen::Controls::Base::RecurseLayout(class Gwen::Skin::Base *)
143: protected: virtual void __thiscall Gwen::Controls::Base::Layout(class Gwen::Skin::Base *)
144: public: virtual void __thiscall Gwen::Controls::Button::PostLayout(class Gwen::Skin::Base *)
145: public: virtual void __thiscall Gwen::Controls::Base::DragAndDrop_SetPackage(bool, class std::basic_string<char, struct std::char_traits<char>, class std::allocator<char>> const &, void *)
146: public: virtual bool __thiscall Gwen::Controls::Base::DragAndDrop_Draggable(void)
147: public: virtual bool __thiscall Gwen::Controls::Base::DragAndDrop_ShouldStartDrag(void)
148: public: virtual void __thiscall Gwen::Controls::Base::DragAndDrop_StartDragging(struct Gwen::DragAndDrop::Package *, int, int)
149: public: virtual struct Gwen::DragAndDrop::Package * __thiscall Gwen::Controls::Base::DragAndDrop_GetPackage(int, int)
150: public: virtual void __thiscall Gwen::Controls::Base::DragAndDrop_EndDragging(bool, int, int)
151: public: virtual void __thiscall Gwen::Controls::Base::DragAndDrop_HoverEnter(struct Gwen::DragAndDrop::Package *, int, int)
152: public: virtual void __thiscall Gwen::Controls::Base::DragAndDrop_HoverLeave(struct Gwen::DragAndDrop::Package *)
153: public: virtual void __thiscall Gwen::Controls::Base::DragAndDrop_Hover(struct Gwen::DragAndDrop::Package *, int, int)
154: public: virtual bool __thiscall Gwen::Controls::Base::DragAndDrop_HandleDrop(struct Gwen::DragAndDrop::Package *, int, int)
155: public: virtual bool __thiscall Gwen::Controls::Base::DragAndDrop_CanAcceptPackage(struct Gwen::DragAndDrop::Package *)
156: public: virtual void __thiscall Gwen::Controls::Base::Anim_WidthIn(float, float, float)
157: public: virtual void __thiscall Gwen::Controls::Base::Anim_HeightIn(float, float, float)
158: public: virtual void __thiscall Gwen::Controls::Base::Anim_WidthOut(float, bool, float, float)
159: public: virtual void __thiscall Gwen::Controls::Base::Anim_HeightOut(float, bool, float, float)
160: public: virtual class Gwen::Controls::Base * __thiscall Gwen::Controls::Button::DynamicCast(char const *)
161: public: virtual class Gwen::TextObject __thiscall Gwen::Controls::Base::GetChildValue(class std::basic_string<char, struct std::char_traits<char>, class std::allocator<char>> const &)
162: public: virtual class Gwen::TextObject __thiscall Gwen::Controls::Label::GetValue(void)
163: public: virtual void __thiscall Gwen::Controls::Label::SetValue(class Gwen::TextObject const &)
164: public: virtual void __thiscall Gwen::Controls::Button::DoAction(void)
165: public: virtual void __thiscall Gwen::Controls::Button::SetAction(class Gwen::Event::Handler *, void (__thiscall Gwen::Event::Handler::*)(struct Gwen::Event::Information const &), struct Gwen::Event::Packet const &)
166: public: virtual class Gwen::ControlList __thiscall Gwen::Controls::Base::GetNamedChildren(class std::basic_string<char, struct std::char_traits<char>, class std::allocator<char>> const &, bool)
167: public: virtual int __thiscall Gwen::Controls::Base::GetNamedChildren(class Gwen::ControlList &, class std::basic_string<char, struct std::char_traits<char>, class std::allocator<char>> const &, bool)
168: public: virtual char const * __thiscall Gwen::Controls::Button::GetBaseTypeName(void)
169: public: virtual void __thiscall Gwen::Controls::Label::SetText(class Gwen::TextObject const &, bool)
170: public: virtual class Gwen::TextObject const & __thiscall Gwen::Controls::Label::GetText(void)const
171: public: virtual void __thiscall Gwen::Controls::Button::SizeToContents(void)
172: public: virtual void __thiscall Gwen::Controls::Label::SetAlignment(int)
173: public: virtual int __thiscall Gwen::Controls::Label::GetAlignment(void)
174: public: virtual void __thiscall Gwen::Controls::Label::SetFont(struct Gwen::Font *)
175: public: virtual void __thiscall Gwen::Controls::Label::SetFont(class std::basic_string<wchar_t, struct std::char_traits<wchar_t>, class std::allocator<wchar_t>>, int, bool)
176: public: virtual struct Gwen::Font * __thiscall Gwen::Controls::Label::GetFont(void)
177: public: virtual void __thiscall Gwen::Controls::Label::SetTextColor(struct Gwen::Color const &)
178: public: virtual void __thiscall Gwen::Controls::Label::SetTextColorOverride(struct Gwen::Color const &)
179: public: virtual int __thiscall Gwen::Controls::Label::TextWidth(void)
180: public: virtual int __thiscall Gwen::Controls::Label::TextRight(void)
181: public: virtual int __thiscall Gwen::Controls::Label::TextHeight(void)
182: public: virtual int __thiscall Gwen::Controls::Label::TextX(void)
183: public: virtual int __thiscall Gwen::Controls::Label::TextY(void)
184: public: virtual int __thiscall Gwen::Controls::Label::TextLength(void)
185: public: virtual void __thiscall Gwen::Controls::Label::SetTextPadding(struct Gwen::Margin const &)
186: public: virtual struct Gwen::Margin const & __thiscall Gwen::Controls::Label::GetTextPadding(void)
187: public: virtual void __thiscall Gwen::Controls::Label::MakeColorNormal(void)
188: public: virtual void __thiscall Gwen::Controls::Label::MakeColorBright(void)
189: public: virtual void __thiscall Gwen::Controls::Label::MakeColorDark(void)
190: public: virtual void __thiscall Gwen::Controls::Label::MakeColorHighlight(void)
191: public: virtual bool __thiscall Gwen::Controls::Label::Wrap(void)
192: public: virtual void __thiscall Gwen::Controls::Label::SetWrap(bool)
193: protected: virtual void __thiscall Gwen::Controls::Label::OnTextChanged(void)
194: public: virtual void __thiscall Gwen::Controls::Button::OnPress(void)
195: public: virtual void __thiscall Gwen::Controls::Button::OnRightPress(void)
196: public: virtual bool __thiscall Gwen::Controls::Button::IsDepressed(void)const
197: public: virtual void __thiscall Gwen::Controls::Button::SetDepressed(bool)
198: public: virtual void __thiscall Gwen::Controls::Button::SetIsToggle(bool)
199: public: virtual bool __thiscall Gwen::Controls::Button::IsToggle(void)const
200: public: virtual bool __thiscall Gwen::Controls::Button::GetToggleState(void)const
201: public: virtual void __thiscall Gwen::Controls::Button::SetToggleState(bool)
202: public: virtual void __thiscall Gwen::Controls::Button::Toggle(void)
203: public: virtual void __thiscall Gwen::Controls::Button::SetImage(class Gwen::TextObject const &, bool)
204: public: virtual void __thiscall Gwen::Controls::Button::SetImageAlpha(float)
]]