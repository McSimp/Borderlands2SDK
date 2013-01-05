function ProcessPackages()

	for i=0,(engine.Objects.Count-1) do

		local obj = engine.Objects:Get(i)
		if IsNull(obj) then goto continue end

		if obj.UObject:IsA(UClass.StaticClass()) then
			classes = classes + 1
			print(obj.UObject:GetFullName())
		end

		::continue::
	end

end