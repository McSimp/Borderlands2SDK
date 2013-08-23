local ffi = require("ffi")
ffi.cdef[[
struct UPackage* LUAFUNC_LoadPackage(struct UPackage* outer, const wchar_t* filename, unsigned long flags)
]]

function TestLoad(name)
	local len = string.len(name) + 1
	local buff = ffi.new("wchar_t[?]", len)
	ffi.C.mbstowcs(buff, name, len)

	local ret = ffi.C.LUAFUNC_LoadPackage(nil, buff, 0)
	print(ret)
	return ret
end

function TestPlay()
	local obj = engine.FindObject("SoundCue TestingPackage.TS3Recording_Cue")
	LocalPlayer():PlaySound(obj, false, false, false, LocalPlayer().Pawn.Mesh:GetBoneLocation("Head", 0), false)
end

function FindNetIndex(idx)
	for i=0,(engine.Objects.Count-1) do
		local obj = engine.Objects:Get(i)
		if IsNull(obj) then goto continue end

		if obj.UObject.NetIndex == idx then print(obj:GetFullName()) return obj end

		::continue::
	end
end

function FindName(idx)
	print(ffi.string(engine.Names:Get(idx).Name))
end

function ChangeMat()
	TestLoad("TestingTexture.upk")
	local mat = engine.FindObject("MaterialInstanceConstant TestingTexture.SmileyFaces_MatConst")
	print(mat)
end

function TestChangeMat()
	local mat = engine.FindObject("MaterialInstanceConstant TestingTexture.SmileyFaces_MatConst")
	print(mat)
	local playerObj = engine.Objects:Get(154198)
	print(playerObj)
	print(playerObj.PlayerMeshComp)
	playerObj.PlayerMeshComp:SetMaterial(0, mat)
end

function ChangeConst()
	local mat = engine.FindObject("MaterialInstanceConstant TestingTexture.SmileyFaces_MatConst")
	print(mat)
	local otherMat = engine.FindObject("MaterialInstanceConstant CD_Skins_Assassin_MainGame.Mati_Gearbox_Body")
	print(otherMat)
	mat:SetParent(otherMat)
	local playerObj = engine.Objects:Get(154198)
	print(playerObj)
	playerObj.PlayerMeshComp:SetMaterial(0, otherMat)
end

-- l print(engine.Objects:Get(206958):GetFullName())
