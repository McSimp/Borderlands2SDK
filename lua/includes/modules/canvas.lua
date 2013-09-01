local ffi = require("ffi")
local error = error
local print = print
local engineHook = engineHook
local engine = engine

local EBlendMode = enums.EBlendMode
local engineCanvas = nil -- make sure it's a struct UCanvas*
local currentTexture = nil
local whiteColor = ffi.new("struct FLinearColor", 1, 1, 1, 1)

module("canvas")

function _SetPos(x, y)
	engineCanvas.UCanvas.CurX = x
	engineCanvas.UCanvas.CurY = y
end

function SetDrawColor(color)
	engineCanvas.UCanvas.DrawColor = color
end

function DrawRect(x, y, w, h)
	_SetPos(x, y)

	local tex = engineCanvas.UCanvas.DefaultTexture

	local drawCol = engineCanvas.UCanvas.DrawColor
	local col = ffi.new("struct FLinearColor", 
		drawCol.R/255,
		drawCol.G/255,
		drawCol.B/255,
		drawCol.A/255)

	engineCanvas:DrawTile(tex, w, h, 0, 0, tex.UTexture2D.SizeX, tex.UTexture2D.SizeY, col, false, EBlendMode.BLEND_Translucent)
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
	if scale == nil then scale = 1 end
	currentTexture = ffi.cast("struct UTexture2D*", tex)
end

function _InternalDrawTexturedRectUV(x, y, w, h, u, v, ul, vl)
	_SetPos(x, y)
	engineCanvas:DrawTile(currentTexture, w, h, u, v, ul, vl, whiteColor, true, EBlendMode.BLEND_Translucent)
end

function DrawTexturedRect(x, y, w, h)
	if currentTexture == nil then error("Current canvas texture is nil") end
	_InternalDrawTexturedRectUV(x, y, w, h, 0, 0, currentTexture.UTexture2D.SizeX, currentTexture.UTexture2D.SizeY)
end

function DrawTexturedRectUV(x, y, w, h, u, v, ul, vl)
	if currentTexture == nil then error("Current canvas texture is nil") end
	_InternalDrawTexturedRectUV(x, y, w, h, u, v, ul, vl)
end

engineHook.Add(engine.Classes.UWillowGameViewportClient.funcs.PostRender, "GetCanvas", function(caller, args)
	engineCanvas = ffi.cast("struct UCanvas*", args.Canvas)
	engineHook.Remove(engine.Classes.UWillowGameViewportClient.funcs.PostRender, "GetCanvas")
end)
