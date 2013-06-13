local ffi = require("ffi")

local FNameMT = {}

function FNameMT.GetName(self)
	return ffi.string(engine.Names:Get(self.Index).Name)
end

ffi.metatype("struct FName", { __index = FNameMT })

