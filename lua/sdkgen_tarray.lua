local ffi = require("ffi")
local engine = engine

local GeneratedTArrays = { "FName" } -- An array of inner type name strings (TODO: Ugh. String table)
local TARRAY_TEMPLATE = [[
struct TArray_%s_ {
	%s* Data;
	int Count;
	int Max;
};
]]

-- innerType should be a UProperty*
function SDKGen.TArrayTypeGenerated(innerType)
	local propTypeClean = SDKGen.GetCleanPropertyType(innerType)
	return table.contains(GeneratedTArrays, propTypeClean)
end

function SDKGen.GenerateTArrayType(innerType)
	local propType = SDKGen.GetPropertyType(innerType)
	local propTypeClean = SDKGen.GetCleanPropertyType(innerType)

	table.insert(GeneratedTArrays, propTypeClean)

	print("[SDKGen] TArray for " .. propType)

	return string.format(TARRAY_TEMPLATE, propTypeClean, propType)
end