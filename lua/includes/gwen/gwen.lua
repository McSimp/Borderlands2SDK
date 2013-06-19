local ffi = require("ffi")

ffi.cdef[[
typedef struct {
	int x;
	int y;
} GwenPoint;

typedef struct {
	int top;
	int bottom;
	int left;
	int right;
} GwenMargin;

typedef struct {
	int x;
	int y;
	int w;
	int h;
} GwenRect;

typedef struct {
	unsigned char r;
	unsigned char g;
	unsigned char b;
	unsigned char a;
} GwenColor;

typedef struct {
	int* VMT;
} GwenControl;

typedef struct TextObject TextObject;

GwenControl* LUAFUNC_CreateNewControl(int controlNum, GwenControl* parent);
TextObject* LUAFUNC_NewTextObject(const char* str);
const char* LUAFUNC_GetTextObjectString(TextObject& obj);
void LUAFUNC_DestroyTextObject(TextObject*);
int LUAFUNC_GetCanvasW();
int LUAFUNC_GetCanvasH();
]]

gwen = {}
gwen.ControlTypes = { Button = 0, WindowControl = 1, HorizontalSlider = 2 }
gwen.meta = {}
gwen._ActiveControls = {} -- TODO: Prevent use after free

POS_NONE = 0
POS_LEFT = 2
POS_RIGHT = 4
POS_TOP = 8
POS_BOTTOM = 16
POS_CENTERV = 32
POS_CENTERH = 64
POS_FILL = 128
POS_CENTER = 96 -- (CenterV | CenterH)

function gwen.GetVFunc(control, idx, typedef)
	return ffi.cast(typedef, control.VMT[idx])
end

function gwen.ControlFromPointer(cdata)
	if cdata == nil then return nil end

	-- First check the _ActiveControls table
	local control = gwen._ActiveControls[PtrToNum(cdata)]
	if control ~= nil then
		return control
	end

	local tbl = { control = cdata }
	local luaControl = setmetatable(tbl, gwen.meta[gwen.meta.Base.GetTypeName(tbl)] or "Base")
	gwen._ActiveControls[PtrToNum(control)] = luaControl

	return luaControl
end

-- TODO: Automatic GC
function gwen.GetTextObject(str)
	return ffi.C.LUAFUNC_NewTextObject(str)
end

function gwen.FreeTextObject(obj)
	ffi.C.LUAFUNC_DestroyTextObject(obj)
end

function gwen.GetStringFromTextObject(obj)
	return ffi.string(ffi.C.LUAFUNC_GetTextObjectString(obj))
end

function gwen.CreateControl(controlType, parent)
	local ctrlNum = gwen.ControlTypes[controlType]
	if ctrlNum == nil then
		error(controlType .. " is not a valid control type")
	end

	if parent ~= nil then
		parent = parent:_GetInternalControl()
	end

	-- Call to SDK to create a control and get all the C++ stuff done
	local control = ffi.C.LUAFUNC_CreateNewControl(ctrlNum, parent)
	if control == nil then
		error("An error occurred while creating the control")
	end

	local luaControl = setmetatable({ control = control }, gwen.meta[controlType])
	gwen._ActiveControls[PtrToNum(control)] = luaControl

	return luaControl
end

function gwen.ScrW()
	return ffi.C.LUAFUNC_GetCanvasW()
end

function gwen.ScrH()
	return ffi.C.LUAFUNC_GetCanvasH()
end

function Color(r, g, b, a)
	local obj = ffi.new("GwenColor")

	obj.r = math.clamp(tonumber(r), 0, 255)
	obj.g = math.clamp(tonumber(g), 0, 255)
	obj.b = math.clamp(tonumber(b), 0, 255)
	obj.a = math.clamp(tonumber(a), 0, 255)

	return obj
end

include("callbacks.lua")
include("base.lua")
include("label.lua")
include("button.lua")
include("resizablecontrol.lua")
include("windowcontrol.lua")
include("slider.lua")
include("horizontalslider.lua")