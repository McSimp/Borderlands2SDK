local ffi = require("ffi")

ffi.cdef[[
typedef bool (*tCallFunctionHook) (struct UObject*, struct FFrame&, void* const Result, struct UFunction*);
]]

module("scriptHook")