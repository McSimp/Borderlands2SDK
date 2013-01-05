--[[
	This file contains the necessary classes for generating the SDK
	DO NOT MODIFY
]]

local ffi = require("ffi")

ffi.cdef[[
	struct UObject_Data { 
		struct FPointer 	VfTableObject;
		struct FPointer		HashNext;
		struct FQWord 		ObjectFlags;
		struct FPointer 	HashOuterNext;
		struct FPointer 	StateFrame;
		struct UObject* 	Linker;
		struct FPointer 	LinkerIndex;
		int 				ObjectInternalInteger;
		int 				NetIndex;
		struct UObject* 	Outer;
		struct FName 		Name;
		struct UClass* 		Class;
		struct UObject* 	ObjectArchetype;
	};

	struct UObject {
		struct UObject_Data UObject;
	};

	struct UField_Data {
		struct UField* Next;
	};

	struct UField {
		struct UObject_Data 	UObject;
		struct UField_Data 		UField;
	};

	struct UEnum_Data {
		struct TArray Names;
	};

	struct UEnum {
		struct UObject_Data 	UObject;
		struct UField_Data 		UField;
		struct UEnum_Data 		UEnum;
	};

	struct UConst_Data {
		struct FString Value;
	};

	struct UConst {
		struct UObject_Data 	UObject;
		struct UField_Data 		UField;
		struct UConst_Data 		UConst;
	};

	struct UStruct_Data {
		unsigned char 	Unknown1[0x8];
		struct UField* 	SuperField;
		struct UField* 	Children;
		unsigned short 	PropertySize;
		unsigned short 	Unknown2;
		unsigned char 	Unknown3[0x38];
	};

	struct UStruct {
		struct UObject_Data 	UObject;
		struct UField_Data 		UField;
		struct UStruct_Data 	UStruct;
	};

	struct UScriptStruct_Data {
		unsigned char Unknown[0x1C];
	};

	struct UScriptStruct {
		struct UObject_Data 		UObject;
		struct UField_Data 			UField;
		struct UStruct_Data 		UStruct;
		struct UScriptStruct_Data 	UScriptStruct;
	};

	struct UFunction_Data {
		unsigned long 		FunctionFlags;
		unsigned short 		iNative;
		unsigned short 		RepOffset;
		struct FName 		FriendlyName;
		unsigned short 		NumParms;
		unsigned short 		ParmsSize;
		unsigned long 		ReturnValueOffset;
		unsigned char 		Unknown[0x4];
		void* 				Func;
	};

	struct UFunction {
		struct UObject_Data 	UObject;
		struct UField_Data 		UField;
		struct UStruct_Data 	UStruct;
		struct UFunction_Data 	UFunction;
	}

	struct UState_Data {
		unsigned char Unknown[0x44];
	}

	struct UState {
		struct UObject_Data 	UObject;
		struct UField_Data 		UField;
		struct UStruct_Data 	UStruct;
		struct UState_Data 		UState;
	}

	struct UClass_Data {
		unsigned char Unknown[0x100];
	};

	struct UClass {
		struct UObject_Data 	UObject;
		struct UField_Data 		UField;
		struct UStruct_Data 	UStruct;
		struct UState_Data 		UState;
		struct UClass_Data 		UClass;
	};

	struct UProperty_Data {
		unsigned long 		ArrayDim;
		unsigned long 		ElementSize;
		struct FQWord 		PropertyFlags;
		unsigned short 		PropertySize;
		unsigned short 		Unknown1;
		unsigned char 		Unknown2[0xC];
		unsigned long 		Offset;
		unsigned char 		Unknown3[0x1C];
	};

	struct UProperty {
		struct UObject_Data 	UObject;
		struct UField_Data 		UField;
		struct UProperty_Data 	UProperty;
	};

	struct UByteProperty_Data {
		struct UEnum* Enum;
	};

	struct UByteProperty {
		struct UObject_Data 		UObject;
		struct UField_Data 			UField;
		struct UProperty_Data 		UProperty;
		struct UByteProperty_Data 	UByteProperty;
	};

	struct UIntProperty_Data {

	};

	struct UIntProperty {
		struct UObject_Data 		UObject;
		struct UField_Data 			UField;
		struct UProperty_Data 		UProperty;
		struct UIntProperty_Data 	UIntProperty;
	};

	struct UFloatProperty_Data {

	};

	struct UFloatProperty {
		struct UObject_Data 		UObject;
		struct UField_Data 			UField;
		struct UProperty_Data 		UProperty;
		struct UFloatProperty_Data 	UFloatProperty;
	};

	struct UBoolProperty_Data {
		unsigned long BitMask;
	};

	struct UBoolProperty {
		struct UObject_Data 		UObject;
		struct UField_Data 			UField;
		struct UProperty_Data 		UProperty;
		struct UBoolProperty_Data 	UBoolProperty;
	};

	struct UStrProperty_Data {

	};

	struct UStrProperty {
		struct UObject_Data 		UObject;
		struct UField_Data 			UField;
		struct UProperty_Data 		UProperty;
		struct UStrProperty_Data 	UStrProperty;
	};

	struct UNameProperty_Data {

	};

	struct UNameProperty {
		struct UObject_Data 		UObject;
		struct UField_Data 			UField;
		struct UProperty_Data 		UProperty;
		struct UNameProperty_Data 	UNameProperty;
	};

	struct UDelegateProperty_Data {
		unsigned char Unknown[0x8];
	};

	struct UDelegateProperty {
		struct UObject_Data 			UObject;
		struct UField_Data 				UField;
		struct UProperty_Data 			UProperty;
		struct UDelegateProperty_Data 	UDelegateProperty;
	};

	struct UObjectProperty_Data {
		struct UClass* PropertyClass;
	};

	struct UObjectProperty {
		struct UObject_Data 			UObject;
		struct UField_Data 				UField;
		struct UProperty_Data 			UProperty;
		struct UObjectProperty_Data 	UObjectProperty;
	};

	struct UClassProperty_Data {
		struct UClass* MetaClass;
	};

	struct UClassProperty {
		struct UObject_Data 			UObject;
		struct UField_Data 				UField;
		struct UProperty_Data 			UProperty;
		struct UObjectProperty_Data 	UObjectProperty;
		struct UClassProperty_Data 		UClassProperty;
	};

	struct UInterfaceProperty_Data {
		struct UClass* InterfaceClass;
	};

	struct UInterfaceProperty {
		struct UObject_Data 			UObject;
		struct UField_Data 				UField;
		struct UProperty_Data 			UProperty;
		struct UInterfaceProperty_Data 	UInterfaceProperty;
	};

	struct UStructProperty_Data {
		struct UStruct* Struct;
	};

	struct UStructProperty {
		struct UObject_Data 			UObject;
		struct UField_Data 				UField;
		struct UProperty_Data 			UProperty;
		struct UStructProperty_Data 	UStructProperty;
	};

	struct UArrayProperty_Data {
		struct UClass* Inner;
	};

	struct UArrayProperty {
		struct UObject_Data 		UObject;
		struct UField_Data 			UField;
		struct UProperty_Data 		UProperty;
		struct UArrayProperty_Data 	UArrayProperty;
	};

	struct UMapProperty_Data {
		struct UProperty* Key;
		struct UProperty* Value;
	};

	struct UMapProperty {
		struct UObject_Data 		UObject;
		struct UField_Data 			UField;
		struct UProperty_Data 		UProperty;
		struct UMapProperty_Data 	UMapProperty;
	};
]]