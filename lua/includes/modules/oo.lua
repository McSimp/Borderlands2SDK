local error = error
local string = string

local oo = {}

function oo.NotImplemented(class, name, ...)
	class[name] = function(self) 
		error(string.format("Missing function definition for %q in %q", name, self._ClassName))
	end
end

function oo.InheritClass(baseClass, newName)
	local newClass = table.copy(class)
	newClass._ClassName = newName
	newClass._BaseClass = baseClass
	return newClass
end

function oo.CreateClass(name)
	local class = {}
	class._ClassName = name
	class.New = function()
		local obj = setmetatable({}, { __index = class })
		return obj
	end

	return class
end
