local ffi = require("ffi")

local RendererBase = require("gwen.renderers.base")
local BL2Renderer = oo.InheritClass(RendererBase, "Gwen.Renderer.BL2")

local engine = engine
local canvas = canvas
local whiteColor = Color(255, 255, 255, 255)

function BL2Renderer:SetDrawColor(color)
	if color == nil then
		canvas.SetDrawColor(whiteColor)
	else
		canvas.SetDrawColor(color)
	end
end

function BL2Renderer:DrawTexturedRect(tex, bounds, u, v, ul, vl)
	canvas.SetTexture(tex)
	canvas.DrawTexturedRectUV(bounds.x, bounds.y, bounds.w, bounds.h, u, v, ul, vl)
end

function BL2Renderer:DrawFilledRect(bounds)
	canvas.DrawRect(bounds.x, bounds.y, bounds.w, bounds.h)
end

function BL2Renderer:LoadTexture(texName)
	local tex = engine.FindObject(texName, engine.Classes.UTexture2D)
	if tex == nil then
		error("Texture could not be found")
	end

	return ffi.cast("struct UTexture2D*", tex)
end

function BL2Renderer:LoadFont(fontName)
	local font = engine.FindObject(fontName, engine.Classes.UFont)
	if font == nil then
		error("Font could not be found")
	end

	return ffi.cast("struct UFont*", font)
end

return BL2Renderer
