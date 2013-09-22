require("util")

local gwen = {}

gwen.Renderer = {}
gwen.Skin = {}

gwen.Renderer.Base = require("renderers.base")
gwen.Renderer.BL2 = require("renderers.bl2")

gwen.Skin.Base = require("skins.base")
gwen.Skin.Textured = require("skins.textured")

return gwen
