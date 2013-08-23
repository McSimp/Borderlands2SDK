local ffi = require("ffi")

-- Canvas rendering

function Color(r, g, b, a)
	if a == nil then a = 255 end
	local col = ffi.new("struct FColor")

	col.B = math.clamp(tonumber(b), 0, 255)
	col.G = math.clamp(tonumber(g), 0, 255)
	col.R = math.clamp(tonumber(r), 0, 255)
	col.A = math.clamp(tonumber(a), 0, 255)

	return col
end

canvas = {}
local engineCanvas = nil -- make sure it's a struct UCanvas*
local currentTexture = nil
local whiteColor = ffi.new("struct FLinearColor", 1, 1, 1, 1)

function canvas._SetPos(x, y)
	engineCanvas.UCanvas.CurX = x
	engineCanvas.UCanvas.CurY = y
end

function canvas.SetDrawColor(color)
	engineCanvas.UCanvas.DrawColor = color
end

function canvas.DrawRect(x, y, w, h)
	canvas._SetPos(x, y)

	local tex = engineCanvas.UCanvas.DefaultTexture

	local drawCol = engineCanvas.UCanvas.DrawColor
	local col = ffi.new("struct FLinearColor", 
		drawCol.R/255,
		drawCol.G/255,
		drawCol.B/255,
		drawCol.A/255)

	engineCanvas:DrawTile(tex, w, h, 0, 0, tex.UTexture2D.SizeX, tex.UTexture2D.SizeY, col, false, enums.EBlendMode.BLEND_Translucent)
end

function canvas.DrawBorderedRect(x, y, w, h)
	canvas.DrawRect(x, y, 1, h) -- left
	canvas.DrawRect(x + w - 1, y, 1, h) -- right
	canvas.DrawRect(x + 1, y, w - 2, 1) -- top
	canvas.DrawRect(x + 1, y + h - 1, w - 2, 1) -- bottom
end

function canvas.DrawLine(startX, startY, endX, endY)
	engineCanvas:Draw2DLine(startX, startY, endX, endY, engineCanvas.UCanvas.DrawColor)
end

function canvas.SetFont(font)
	engineCanvas.UCanvas.Font = font
end

function canvas.DrawText(x, y, text)
	canvas._SetPos(x, y)
	engineCanvas:DrawText(text, false, 1, 1)
end

function canvas.GetTextSize(text)
	return engineCanvas:TextSize(text)
end

function canvas.SetTexture(tex)
	if scale == nil then scale = 1 end
	currentTexture = ffi.cast("struct UTexture2D*", tex)
end

function canvas.DrawTexturedRect(x, y, w, h)
	if currentTexture == nil then error("Current texture is nil") end
	canvas._SetPos(x, y)
	engineCanvas:DrawTile(currentTexture, w, h, 0, 0, currentTexture.UTexture2D.SizeX, currentTexture.UTexture2D.SizeY, whiteColor, false, enums.EBlendMode.BLEND_Translucent)
end

engineHook.Add(engine.Classes.UWillowGameViewportClient.funcs.PostRender, "GetCanvas", function(caller, args)
	engineCanvas = ffi.cast("struct UCanvas*", args.Canvas)
	print("Got canvas", engineCanvas)
	engineHook.Remove(engine.Classes.UWillowGameViewportClient.funcs.PostRender, "GetCanvas")
end)

local testTexture = engine.FindObject("Texture2D GwenTexturePkg.DefaultSkin")

engineHook.Remove(engine.Classes.UWillowGameViewportClient.funcs.PostRender, "DrawTest")
engineHook.Add(engine.Classes.UWillowGameViewportClient.funcs.PostRender, "DrawTest", function(caller, args)
	--[[
	canvas.SetDrawColor(Color(0,125,0, 100))
	canvas.DrawRect(400, 100, 200, 200)

	canvas.SetDrawColor(Color(125,0,0, 255))
	canvas.DrawBorderedRect(400, 100, 200, 200)

	canvas.SetDrawColor(Color(255,255,255, 255))
	canvas.DrawText(450, 150, "Hello")
	]]
	canvas.SetTexture(testTexture)
	canvas.DrawTexturedRect(100, 100, 512, 512)
end)
