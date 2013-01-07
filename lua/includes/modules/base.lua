function IsNull(ptr)
	return ptr == nil
end

function NotNull(ptr)
	return ptr ~= nil
end

function istable(data)
	return type(data) == "table"
end

function PrintTable ( t, indent, done )

    done = done or {}
    indent = indent or 0

    for key, value in pairs (t) do

        print( string.rep ("\t", indent) )

        if  istable(value) and  not done[value] then

            done [value] = true
            print( tostring(key) .. ":" )
            PrintTable (value, indent + 2, done)

        else

            print( tostring (key) .. "\t=\t" .. tostring(value) )

        end

    end

end

loadedClasses = {}