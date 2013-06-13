local bit = require("bit")

module("flags")

function IsSet(field, flag)
	return bit.band(field, flag) ~= 0
end
