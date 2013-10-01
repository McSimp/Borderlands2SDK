local RendererBase = oo.CreateClass("Gwen.Renderer.Base")

function RendererBase:Init()
	return
end

oo.NotImplemented(RendererBase, "SetDrawColor", "color")
oo.NotImplemented(RendererBase, "DrawTexturedRect", "tex", "bounds", "u", "v", "ul", "vl")
oo.NotImplemented(RendererBase, "DrawFilledRect", "bounds")
oo.NotImplemented(RendererBase, "LoadTexture", "texName")
oo.NotImplemented(RendererBase, "LoadFont", "fontName")

return RendererBase
