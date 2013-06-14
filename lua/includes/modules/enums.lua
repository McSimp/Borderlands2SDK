local _enums = {}

function _enums.MakeEnum(name, identifiers)
	local enum = {}
	for i=1,#identifiers do
		enum[identifiers[i]] = (i-1)
	end

	_enums[name] = enum
end

enums = _enums