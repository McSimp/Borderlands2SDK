local ffi = require("ffi")

ffi.cdef[[
	struct FNameEntry {
		unsigned char Unknown[0x10];
		char Name[0x10];
	};

	struct FName { 
		int Index;
		unsigned char Unknown[0x4];
	};
]]

local FNameMT = {}

function FNameMT.GetName(self)
	return ffi.string(engine.Names:Get(self.Index).Name)
end

ffi.metatype("struct FName", { __index = FNameMT })