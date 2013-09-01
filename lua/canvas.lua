local ffi = require("ffi")

local testTexture = engine.FindObject("Texture2D GwenTexturePkg.DefaultSkin")

function CreateTextureNormal( _x, _y, _w, _h )

	--_x = _x / 512
	--_y = _y / 512
	--_w = _w / 512
	--_h = _h / 512
		
	return function( x, y, w, h )
		
		canvas.DrawTexturedRectUV( x, y, w, h, _x, _y, _w, _h )

	end

end

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


	--canvas.DrawTexturedRectUV(800, 100, 512, 512, 0, 0, 512, 512)
	local close = CreateTextureNormal(32, 448, 31, 31)
	close(800, 200, 31, 31)
end)
