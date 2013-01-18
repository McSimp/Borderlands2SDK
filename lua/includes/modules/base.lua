function IsNull(ptr)
	return ptr == nil
end

function NotNull(ptr)
	return ptr ~= nil
end

function IsTable(data)
	return type(data) == "table"
end

function PrintTable ( t, indent, done )

	done = done or {}
	indent = indent or 0

	for key, value in pairs (t) do

		print( string.rep ("\t", indent) )

		if  IsTable(value) and  not done[value] then

			done [value] = true
			print( tostring(key) .. ":" )
			PrintTable (value, indent + 2, done)

		else

			print( tostring (key) .. "\t=\t" .. tostring(value) )

		end

	end

end

-- Taken from http://lua-users.org/wiki/PitLibTablestuff
function table.copy(t, lookup_table)
	local copy = {}
	for i,v in pairs(t) do
		if not IsTable(t) then
			copy[i] = v
		else
			lookup_table = lookup_table or {}
			lookup_table[t] = copy
			if lookup_table[v] then
				copy[i] = lookup_table[v] -- we already copied this table. reuse the copy.
			else
				copy[i] = table.copy(v,lookup_table) -- not yet copied. copy it.
			end
		end
	end
	return copy
end


function table.contains(table, element)
	for _,v in pairs(table) do
		if v == element then
			return true
		end
	end
	return false
end

local ffi = require("ffi")

function PtrToNum(ptr)
	return tonumber(ffi.cast("unsigned int", ptr))
end

loadedClasses = {}