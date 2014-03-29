local ffi = require("ffi")
gwen = require("gwen.gwen")

engine.LoadPackage("GwenTexturePkg.upk")

--[[
local testTexture = engine.FindObject("Texture2D GwenTexturePkg.DefaultSkin")

engineHook.Remove(engine.Classes.UWillowGameViewportClient.funcs.PostRender, "DrawTest")
engineHook.Add(engine.Classes.UWillowGameViewportClient.funcs.PostRender, "DrawTest", function(caller, args)
	canvas.SetTexture(testTexture)
	canvas.SetDrawColor(Color(255,0,0))
	canvas.DrawTexturedRect(100, 100, 512, 512)
end)
]]

local renderer = gwen.Renderer.BL2.New()
local skin = gwen.Skin.Textured.New()
skin:Init(renderer, "Texture2D GwenTexturePkg.DefaultSkin", "Font UI_Fonts.Font_Hud_Medium")

engineHook.Remove("UWillowGameViewportClient", "eventPostRender", "DrawTest")
engineHook.Add("UWillowGameViewportClient", "eventPostRender", "DrawTest", function(caller, args)
	skin.Textures.Input.Button.Normal:Draw(renderer, GwenRect(100, 20, 100, 20))
	skin.Textures.Input.Button.Hovered:Draw(renderer, GwenRect(100, 50, 100, 20))
end)
