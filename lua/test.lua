local ffi = require("ffi")
local bit = require("bit")

--[[
for i=0,(engine.Objects.Count-1) do

	local obj = engine.Objects:Get(i)
	if IsNull(obj) then goto continue end
	if not obj:IsA(engine.Classes.UByteProperty) then goto continue end

	obj = ffi.cast("struct UByteProperty*", obj)

	if NotNull(obj.UByteProperty.Enum) then
		print(obj:GetFullName() .. " => " .. tostring(obj.UByteProperty.Enum))
	end

	::continue::
end
]]

--[[
local name, val = debug.getupvalue(engine.FindClass, 3)
print(name, val)
PrintTable(val)
]]

--[[
DWORD GCRCTable[256];

inline DWORD appStrihash( const TCHAR* Data )
{
	DWORD Hash=0;
	while( *Data )
	{
		TCHAR Ch = appToUpper(*Data++);
		WORD  B  = Ch;
		Hash     = ((Hash >> 8) & 0x00FFFFFF) ^ GCRCTable[(Hash ^ B) & 0x000000FF];
		B        = Ch>>8;
		Hash     = ((Hash >> 8) & 0x00FFFFFF) ^ GCRCTable[(Hash ^ B) & 0x000000FF];
	}
	return Hash;
}

FORCEINLINE INT GetIndex() const
{
	return Index >> NAME_INDEX_SHIFT;
}

InName is char*
INT iHash = appStrihash( InName ) & (ARRAY_COUNT(NameHash)-1);

for( FNameEntry* Hash=NameHash[iHash]; Hash; Hash=Hash->HashNext )
	{
		// Compare the passed in string, either ANSI or TCHAR.
		if( ( bIsPureAnsi && Hash->IsEqual( AnsiName )) 
		||  (!bIsPureAnsi && Hash->IsEqual( InName )) )
		{
			// Got the FName
			Hash->GetIndex()

			return;
		}
	}



]]

--local func = ffi.cast("tProcessEvent", 0x65C820)

function SetScale(scale)
	local setScaleFunc = engine.Objects:Get(11518)
	setScaleFunc = ffi.cast("struct UFunction*", setScaleFunc)
	print(setScaleFunc)

	local parms = ffi.new("struct USkeletalMeshComponent_execGetBoneNames_Parms")
	print(bit.tohex(setScaleFunc.UFunction.FunctionFlags))
	setScaleFunc.UFunction.FunctionFlags = bit.bor(setScaleFunc.UFunction.FunctionFlags, bit.bnot(0x400))
	--print(bit.tohex(getengver.UFunction.FunctionFlags))
	print(parms)

	local pc = engine.Objects:Get(178373)
	print(pc:GetFullName())

	print("Calling it now")
	func(pc, setScaleFunc, parms, nil)

	setScaleFunc.UFunction.FunctionFlags = bit.bor(setScaleFunc.UFunction.FunctionFlags, 0x400)
	--print(bit.tohex(getengver.UFunction.FunctionFlags))
	--print(parms.ReturnValue.Index)
	print(parms.BoneNames.Count)
	for k,v in ipairs(parms.BoneNames) do
		print(v:GetName())
	end
end

function SetScale2()
	local setScaleFunc = engine.Objects:Get(11359)
	setScaleFunc = ffi.cast("struct UFunction*", setScaleFunc)
	print(setScaleFunc)

	local parms = ffi.new("struct USkeletalMeshComponent_execSetSkeletalMesh_Parms")
	print(bit.tohex(setScaleFunc.UFunction.FunctionFlags))
	setScaleFunc.UFunction.FunctionFlags = bit.bor(setScaleFunc.UFunction.FunctionFlags, bit.bnot(0x400))
	--print(bit.tohex(getengver.UFunction.FunctionFlags))
	print(parms)

	local a = engine.Objects:Get(187265)
	parms.NewMesh = ffi.cast("struct USkeletalMesh*", a)
	parms.bKeepSpaceBases = false

	local pc = engine.Objects:Get(178373)
	print(pc:GetFullName())

	print("Calling it now")
	func(pc, setScaleFunc, parms, nil)

	setScaleFunc.UFunction.FunctionFlags = bit.bor(setScaleFunc.UFunction.FunctionFlags, 0x400)
	--print(bit.tohex(getengver.UFunction.FunctionFlags))
	--print(parms.ReturnValue.Index)
end

function GetAllPrims()
	for i=0,(engine.Objects.Count-1) do
		local obj = engine.Objects:Get(i)
		if IsNull(obj) then goto continue end
		if not obj:IsA(engine.Classes.APawn) then goto continue end

		print(string.format("%d: %s", obj.Index, obj:GetFullName()))

		::continue::
	end
end

--GetAllPrims()

function Benchmark()
	local band, bnot, rshift = bit.band, bit.bnot, bit.rshift

	local sum = 0
	local start = os.clock()
	for i=0,100000000 do
		sum = sum + band(rshift(band((32 - band(i, 31)), bnot(7)), 3), 3)
	end

	local elapsed = os.clock() - start
	print(string.format("%.3f = %d", elapsed, sum))
end

function Benchmark2()
	local sum = 0
	local start = os.clock()
	for i=0,100000000 do
		sum = sum + math.floor((32 - (i % 32)) / 8)
	end

	local elapsed = os.clock() - start
	print(string.format("%.3f = %d", elapsed, sum))
end

--[[
print(bit.band(0x80, 0x100))
if bit.band(0x400880, 0x100) then
	print("LOLOOLL")
end
]]

local pc = engine.FindObject("WillowPlayerController TheWorld.PersistentLevel.WillowPlayerController", engine.Classes.AWillowPlayerController)
pc = ffi.cast("struct AWillowPlayerController*", pc)
LocalPlayer = pc
--local time = 1/40
local time = 2

function DebugHook(type)
	local info = debug.getinfo(2,"nS")

	--print(info.short_src .. ":" .. line)
	print(info.short_src .. ":" .. info.linedefined)
end

-- l print(LocalPlayer.Pawn.WorldInfo.PawnList.Mesh.Bounds.BoxExtent)

function MyHook()
	local target = pc.AController.Pawn.AActor.WorldInfo.AWorldInfo.PawnList
	while NotNull(target) do
		if not target.AActor.bDeleteMe and target ~= pc.AController.Pawn then
			local extent = target.APawn.Mesh.UPrimitiveComponent.Bounds.BoxExtent
			print(extent.X, extent.Y, extent.Z)
			local location = target.AActor.Location
			
			pc:DrawDebugBox(location, extent, 0, 255, 0, false)
		end
		target = target.APawn.NextPawn
	end

	return true
end

function MyHook2()
	local target = pc.Pawn.WorldInfo.PawnList
	while NotNull(target) do
		if not target.bDeleteMe and target ~= pc.Pawn then
			pc:DrawDebugBox(target.Location, target.Mesh.Bounds.BoxExtent, 0, 255, 0, false)
		end
		target = target.NextPawn
	end

	return true
end

function GetArg(arg, pParms)
	local field = ffi.cast(arg.castTo, pParms + arg.offset)
	--print(arg.castTo, arg.offset, pParms, field)

	return field[0]
	--return true
end

function CallFuncHook(pObject, pFunction, pParms, pResult)
	--print("Func hook called")
	--debug.sethook(DebugHook, "c")
	local args = engine._FuncsInternal[PtrToNum(pFunction)].args

	local argData = {}
	for i=1,#args do
		--print("Getting arg")
		table.insert(argData, GetArg(args[i], pParms))
	end

	--print("Calling myhook with the shit")
	MyHook2(unpack(argData))

	--print("Unhookinh")
	--ffi.C.LUAFUNC_RemoveHook("Function WillowGame.WillowGameViewportClient.PostRender")

	--debug.sethook()
	return true
end

function TestCallback(pObject, pFunction, pParms, pResult)
	print("Got called: " .. pFunction:GetName())
	print(#engine._FuncsInternal[PtrToNum(pFunction)].args)

	ffi.C.LUAFUNC_RemoveHook("Function WillowGame.WillowGameViewportClient.PostRender")
	return true
end

ffi.cdef[[
//typedef bool (tProcessEventHook) (struct UObject*, struct UFunction*, char*, void*);
//int LUAFUNC_HookFunction(const char* funcName, tProcessEventHook* funcHook);
//int LUAFUNC_RemoveHook(const char* funcName);
]]
--[[
FuncHook = ffi.cast("tProcessEventHook*", CallFuncHook)

function AddHook()
	ffi.C.LUAFUNC_HookFunction("Function WillowGame.WillowGameViewportClient.PostRender", FuncHook)
end

function RemoveHook()
	ffi.C.LUAFUNC_RemoveHook("Function WillowGame.WillowGameViewportClient.PostRender")
	FuncHook:free()
end
]]
--MyHook(nil)
-- l print(engine._ClassesInternal[PtrToNum(LocalPlayer.UObject.Class)])

function AddHook()
	--engineHook.Add(engine.Classes.UWillowGameViewportClient.funcs.PostRender, "Shazbot", MyHook2)
	engineHook.Add(engine.Classes.UWillowGameViewportClient.funcs.PostRender, "GiveMeBoxes", function(pCanvas)
		local target = pc.Pawn.WorldInfo.PawnList
		while NotNull(target) do
			if not target.bDeleteMe and target ~= pc.Pawn then
				pc:DrawDebugBox(target.Location, target.Mesh.Bounds.BoxExtent, 0, 255, 0, false)
			end
			target = target.NextPawn
		end
	end)
end

function RemoveHook()
	engineHook.Remove(engine.Classes.UWillowGameViewportClient.funcs.PostRender, "GiveMeBoxes")
end

