local ffi = require("ffi")

engine.LoadPackage("GwenTexturePkg.upk")

local testTexture = engine.FindObject("Texture2D GwenTexturePkg.DefaultSkin")

engineHook.Remove(engine.Classes.UWillowGameViewportClient.funcs.PostRender, "DrawTest")
engineHook.Add(engine.Classes.UWillowGameViewportClient.funcs.PostRender, "DrawTest", function(caller, args)
	canvas.SetTexture(testTexture)
	canvas.SetDrawColor(Color(255,0,0))
	canvas.DrawTexturedRect(100, 100, 512, 512)
end)
