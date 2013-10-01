require("gwen.util")

local gwen = {}

gwen.Renderer = {}
gwen.Skin = {}

gwen.Renderer.Base = require("gwen.renderers.base")
gwen.Renderer.BL2 = require("gwen.renderers.bl2")

gwen.Skin.Base = require("gwen.skins.base")
gwen.Skin.Textured = require("gwen.skins.textured")

return gwen
