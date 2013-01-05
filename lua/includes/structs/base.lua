--[[
	This file contains the necessary structs for generating the SDK
	DO NOT MODIFY
]]

local ffi = require("ffi")

ffi.cdef[[
	struct TArray {
		unsigned char* Data;
		int Count;
		int Max;
	};

	struct FNameEntry {
		unsigned char Unknown[0x10];
		char Name[0x10];
	};

	struct FName { 
		int Index;
		unsigned char Unknown[0x4];
	};

	struct FString {
		wchar_t* Data;
		int Count;
		int Max;
	}

	struct FScriptDelegate {
		unsigned char Unknown[0xC];
	};

	struct FPointer {
		int Dummy;
	};

	struct FQWord {
		int A;
		int B;
	};
]]