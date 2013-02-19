--[[
	This file contains the necessary classes for generating the SDK
	DO NOT MODIFY
]]

local ffi = require("ffi")

ffi.cdef[[
	struct UObject_Data { 
		const struct FPointer 	VfTableObject;
		const struct UObject*	HashNext;
		const struct FQWord 	ObjectFlags;
		const struct UObject* 	HashOuterNext;
		const struct FPointer 	StateFrame;
		const struct UObject* 	Linker;
		const struct FPointer 	LinkerIndex;
		const int 				Index;
		const int 				NetIndex;
		const struct UObject* 	Outer;
		const struct FName 		Name;
		const struct UClass* 	Class;
		const struct UObject* 	ObjectArchetype;
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

	struct TArray_FName_ {
		struct FName* Data;
		int Count;
		int Max;
	};

	struct UEnum_Data {
		struct TArray_FName_ Names;
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

	struct UComponentProperty_Data {

	};

	struct UComponentProperty {
		struct UObject_Data 			UObject;
		struct UField_Data 				UField;
		struct UProperty_Data 			UProperty;
		struct UObjectProperty_Data 	UObjectProperty;
		struct UComponentProperty_Data 	UComponentProperty;
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
		struct UProperty* Inner;
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
--				 Class Name -   Engine Name   - Base Class
g_loadedClasses["UObject"] = { "Class Core.Object", nil }
g_loadedClasses["UField"] = { "Class Core.Field", "UObject" }
g_loadedClasses["UEnum"] = { "Class Core.Enum", "UField" }
g_loadedClasses["UConst"] = { "Class Core.Const", "UField" }
g_loadedClasses["UStruct"] = { "Class Core.Struct", "UField" }
g_loadedClasses["UScriptStruct"] = { "Class Core.ScriptStruct", "UStruct" }
g_loadedClasses["UFunction"] = { "Class Core.Function", "UStruct" }
g_loadedClasses["UState"] = { "Class Core.State", "UStruct" }
g_loadedClasses["UClass"] = { "Class Core.Class", "UState" }
g_loadedClasses["UProperty"] = { "Class Core.Property", "UField" }
g_loadedClasses["UByteProperty"] = { "Class Core.ByteProperty", "UProperty" }
g_loadedClasses["UIntProperty"] = { "Class Core.IntProperty", "UProperty" }
g_loadedClasses["UFloatProperty"] = { "Class Core.FloatProperty", "UProperty" }
g_loadedClasses["UBoolProperty"] = { "Class Core.BoolProperty", "UProperty" }
g_loadedClasses["UStrProperty"] = { "Class Core.StrProperty", "UProperty" }
g_loadedClasses["UNameProperty"] = { "Class Core.NameProperty", "UProperty" }
g_loadedClasses["UDelegateProperty"] = { "Class Core.DelegateProperty", "UProperty" }
g_loadedClasses["UObjectProperty"] = { "Class Core.ObjectProperty", "UProperty" }
g_loadedClasses["UComponentProperty"] = { "Class Core.ComponentProperty", "UObjectProperty" }
g_loadedClasses["UClassProperty"] = { "Class Core.ClassProperty", "UObjectProperty" }
g_loadedClasses["UInterfaceProperty"] = { "Class Core.InterfaceProperty", "UProperty" }
g_loadedClasses["UStructProperty"] = { "Class Core.StructProperty", "UProperty" }
g_loadedClasses["UArrayProperty"] = { "Class Core.ArrayProperty", "UProperty" }
g_loadedClasses["UMapProperty"] ={ "Class Core.MapProperty", "UProperty" }
