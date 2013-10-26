local ffi = require("ffi")
local error = error
local print = print
local engineHook = engineHook
local engine = engine

local EBlendMode = enums.EBlendMode
local whiteLinearColor = ffi.new("struct FLinearColor", 1, 1, 1, 1)

local engineCanvas = nil -- make sure it's a struct UCanvas*
local currentTexture = nil
local currentLinearColor = whiteLinearColor

module("canvas")

function _SetPos(x, y)
	engineCanvas.UCanvas.CurX = x
	engineCanvas.UCanvas.CurY = y
end

function SetDrawColor(color)
	engineCanvas.UCanvas.DrawColor = color
	currentLinearColor = color:ToLinear()
end

function DrawRect(x, y, w, h)
	_SetPos(x, y)

	local tex = engineCanvas.UCanvas.DefaultTexture
	engineCanvas:DrawTile(tex, w, h, 0, 0, tex.UTexture2D.SizeX, tex.UTexture2D.SizeY, currentLinearColor, false, EBlendMode.BLEND_Translucent)
end

function DrawBorderedRect(x, y, w, h)
	DrawRect(x, y, 1, h) -- left
	DrawRect(x + w - 1, y, 1, h) -- right
	DrawRect(x + 1, y, w - 2, 1) -- top
	DrawRect(x + 1, y + h - 1, w - 2, 1) -- bottom
end

function DrawLine(startX, startY, endX, endY)
	engineCanvas:Draw2DLine(startX, startY, endX, endY, engineCanvas.UCanvas.DrawColor)
end

function SetFont(font)
	engineCanvas.UCanvas.Font = font
end

function DrawText(x, y, text)
	_SetPos(x, y)
	engineCanvas:DrawText(text, false, 1, 1)
end

function GetTextSize(text)
	return engineCanvas:TextSize(text)
end

function SetTexture(tex)
	--if scale == nil then scale = 1 end
	currentTexture = ffi.cast("struct UTexture2D*", tex)
end

function _InternalDrawTexturedRectUV(x, y, w, h, u, v, ul, vl)
	_SetPos(x, y)
	engineCanvas:DrawTile(currentTexture, w, h, u, v, ul, vl, currentLinearColor, true, EBlendMode.BLEND_Translucent)
end

function DrawTexturedRect(x, y, w, h)
	if currentTexture == nil then error("Current canvas texture is nil") end
	_InternalDrawTexturedRectUV(x, y, w, h, 0, 0, currentTexture.UTexture2D.SizeX, currentTexture.UTexture2D.SizeY)
end

function DrawTexturedRectUV(x, y, w, h, u, v, ul, vl)
	if currentTexture == nil then error("Current canvas texture is nil") end
	_InternalDrawTexturedRectUV(x, y, w, h, u, v, ul, vl)
end

function SetClipRect(x, y, w, h)
	engineCanvas:SetOrigin(x, y)
	engineCanvas:SetClip(x + w, y + h)
end

function ResetClip()
	engineCanvas:SetOrigin(0, 0)
	engineCanvas:SetClip(engineCanvas.UCanvas.SizeX, engineCanvas.UCanvas.SizeY)
end

-- TODO: Grab this from the object structure rather than a hook - creates a race condition
-- and may actually be incorrect if the UDN is anything to go by.
engineHook.Add("UWillowGameViewportClient", "eventPostRender", "GetCanvas", function(caller, args)
	engineCanvas = ffi.cast("struct UCanvas*", args.Canvas)
	engineHook.Remove("UWillowGameViewportClient", "eventPostRender", "GetCanvas")
end)
