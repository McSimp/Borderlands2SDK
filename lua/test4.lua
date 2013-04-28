local ffi = require("ffi")

ffi.cdef[[
typedef void (__thiscall *tFrameStep) (struct FFrame*, struct UObject*, void* const);
]]
--local pFrameStep = ffi.cast("tFrameStep", bl2sdk.addrFrameStep)
local pFrameStep = ffi.cast("tFrameStep", 0x4629488)

local lolframe = ffi.new("struct FFrame")

print(lolframe:GetInt())