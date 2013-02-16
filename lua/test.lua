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
	local setScaleFunc = engine.Objects:Get(9668)
	setScaleFunc = ffi.cast("struct UFunction*", setScaleFunc)
	print(setScaleFunc)

	local parms = ffi.new("struct UPrimitiveComponent_execSetScale_Parms")
	print(bit.tohex(getengver.UFunction.FunctionFlags))
	--getengver.UFunction.FunctionFlags = bit.band(getengver.UFunction.FunctionFlags, bit.bnot(0x400))
	--print(bit.tohex(getengver.UFunction.FunctionFlags))
	parms.NewScale = scale
	print(parms)

	print("Calling it now")
	func(pc, setScaleFunc, parms, nil)

	--getengver.UFunction.FunctionFlags = bit.bor(getengver.UFunction.FunctionFlags, 0x400)
	--print(bit.tohex(getengver.UFunction.FunctionFlags))
	print(parms.ReturnValue.Index)
end

function GetOffset()
	print("===================")
	print(ffi.sizeof("struct UObject_Data"))
	print(ffi.sizeof("struct UComponent_Data"))
	print(ffi.sizeof("struct UActorComponent_Data"))
	print(bit.tohex(ffi.offsetof("struct UPrimitiveComponent_Data", "Scale")))
	print(bit.tohex(ffi.offsetof("struct UPrimitiveComponent", "UPrimitiveComponent")))
	print(bit.tohex(ffi.offsetof("struct UPrimitiveComponent", "UComponent")))
	print(bit.tohex(ffi.offsetof("struct UPrimitiveComponent", "UActorComponent")))
	print(bit.tohex(ffi.offsetof("struct UActorComponent_Data", "bNeedsUpdateTransform")))
	print(bit.tohex(ffi.offsetof("struct UActorComponent_Data", "TickGroup")))
end

function GetAllPrims()
	for i=0,(engine.Objects.Count-1) do
		local obj = engine.Objects:Get(i)
		if IsNull(obj) then goto continue end
		if not obj:IsA(engine.Classes.UGearLikenessMeshComponent) then goto continue end

		--if obj.Scale > 0 then
			print(string.format("%s => %s, %s", obj:GetFullName(), obj.bAllowCullDistanceVolume, obj.bPlayerOwnerNoSee))
		--end

		::continue::
	end
end

GetAllPrims()

ffi.cdef[[
struct MyStructLoL
{
	unsigned int VfTable_IIWorldBody; // 0x48 (0x4)
	unsigned int Scene; // 0x4C (0x4)
	unsigned int Owner; // 0x50 (0x4)
	unsigned int bAttached : 1; // 0x54 (0x4)
	unsigned int bSkipChildComponentUpdate : 1; // 0x54 (0x4)
	unsigned int bTickInEditor : 1; // 0x54 (0x4)
	unsigned int bTickInGame : 1; // 0x54 (0x4)
	unsigned int bTickInStatusMenu : 1; // 0x54 (0x4)
	unsigned int bNeedsReattach : 1; // 0x54 (0x4)
	unsigned int bNeedsUpdateTransform : 1; // 0x54 (0x4)
	unsigned int afj : 1; // 0x54 (0x4)
	unsigned int gskskg : 1; // 0x54 (0x4)
	unsigned int asgkfj : 1; // 0x54 (0x4)
	unsigned int gksgkshght : 1; // 0x54 (0x4)
	unsigned char TickGroup; // 0x58 (0x1)
};

struct MyStructUnpacked
{
	unsigned int VfTable_IIWorldBody; // 0x48 (0x4)
	unsigned int Scene; // 0x4C (0x4)
	unsigned int Owner; // 0x50 (0x4)
	unsigned int bitfields;
	unsigned char TickGroup; // 0x58 (0x1)
};
]]

function TestPacking()
	local shazbot = ffi.new("struct MyStructLoL[1]")
	ffi.fill(shazbot[0], ffi.sizeof("struct MyStructLoL"), 0)

	shazbot[0].TickGroup = 0x13
	shazbot[0].bNeedsUpdateTransform = 1
	shazbot[0].Owner = 0x1337

	local unpacked = ffi.cast("struct MyStructUnpacked*", shazbot)

	print(string.format("Size = 0x%X", ffi.sizeof("struct MyStructLoL")))
	print(string.format("bNeedsUpdateTransform = %d", shazbot[0].bNeedsUpdateTransform))
	print(string.format("Owner = 0x%X", unpacked.Owner))
	print(string.format("Packed = 0x%X", unpacked.bitfields))
end

--TestPacking()

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
