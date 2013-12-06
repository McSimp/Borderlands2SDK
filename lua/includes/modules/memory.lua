local ffi = require("ffi")

ffi.cdef[[
	struct FMalloc {
		void** VfTable;
	};

	typedef void (__thiscall *tFMallocFree) (struct FMalloc*, void*);
	typedef void* (__thiscall *tFMallocMalloc) (struct FMalloc*, unsigned long, unsigned long);
]]

local memory = {}

local GMalloc = ffi.cast("struct FMalloc**", bl2sdk.GMalloc)[0]
local FMallocFree = ffi.cast("tFMallocFree", GMalloc.VfTable[3])
local FMallocMalloc = ffi.cast("tFMallocMalloc", GMalloc.VfTable[1])

function memory.Free(ptr)
	return FMallocFree(GMalloc, ptr)
end

function memory.Malloc(size)
	-- 8 is the default alignment
	return FMallocMalloc(GMalloc, size, 8)
end

return memory
