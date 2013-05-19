local ffi = require("ffi")

ffi.cdef[[
void free(void* _Memory);

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

GwenControl* LUAFUNC_CreateNewControl(int controlNum);
TextObject* LUAFUNC_NewTextObject(const char* str);
const char* LUAFUNC_GetTextObjectString(TextObject& obj);
]]

gwen = {}
gwen.Controls = { Button = 0, Window = 1 }
gwen.meta = {}

function gwen.GetVFunc(control, idx, typedef)
	return ffi.cast(typedef, control.VMT[idx])
end

function gwen.ControlFromPointer(cdata)
	if cdata == nil then return nil end

	local tbl = { control = cdata }
	return setmetatable(tbl, gwen.meta[gwen.meta.Base.GetTypeName(tbl)] or "Base")
end

-- TODO: Automatic GC
function gwen.GetTextObject(str)
	return ffi.C.LUAFUNC_NewTextObject(str)
end

function gwen.FreeTextObject(obj)
	ffi.C.free(obj)
end

function gwen.GetStringFromTextObject(obj)
	return ffi.string(ffi.C.LUAFUNC_GetTextObjectString(obj))
end

function Color(r, g, b, a)
	local obj = ffi.new("GwenColor")

	obj.r = math.clamp(tonumber(r), 0, 255)
	obj.g = math.clamp(tonumber(g), 0, 255)
	obj.b = math.clamp(tonumber(b), 0, 255)
	obj.a = math.clamp(tonumber(a), 0, 255)

	return obj
end

include("base.lua")
include("label.lua")
include("button.lua")
include("resizablecontrol.lua")
include("windowcontrol.lua")
