local engine = engine
local IsNull = IsNull

module("UClass")

local _sc

function StaticClass()
	if IsNull(_sc) then
		_sc = engine.FindClassSafe("Class Core.Class")
	end

	return _sc
end