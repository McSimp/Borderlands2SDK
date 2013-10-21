/*
#############################################################################################
# Borderlands 2 (1.0.35.4705) SDK
# Generated with TheFeckless UE3 SDK Generator v1.4_Beta-Rev.51
# Credits: uNrEaL, Tamimego, SystemFiles, R00T88, _silencer, the1domo, K@N@VEL
# Thanks: HOOAH07, lowHertz
# Forums: www.uc-forum.com, www.gamedeception.net
#############################################################################################
*/
#ifdef _MSC_VER
	#pragma pack ( push, 0x4 )
#endif

#include <string>

/*
# ========================================================================================= #
# Classes
# ========================================================================================= #
*/

// Class Core.Object
// 0x003C
class UObject
{
public:
	//struct FPointer                                    VfTableObject;                                    		// 0x0000 (0x0004) [0x0000000000821002]              ( CPF_Const | CPF_Native | CPF_EditConst | CPF_NoExport )
	struct FPointer                                    HashNext;                                         		// 0x0004 (0x0004) [0x0000000000021002]              ( CPF_Const | CPF_Native | CPF_EditConst )
	struct FQWord                                      ObjectFlags;                                      		// 0x0008 (0x0008) [0x0000000000021002]              ( CPF_Const | CPF_Native | CPF_EditConst )
	struct FPointer                                    HashOuterNext;                                    		// 0x0010 (0x0004) [0x0000000000021002]              ( CPF_Const | CPF_Native | CPF_EditConst )
	struct FPointer                                    StateFrame;                                       		// 0x0014 (0x0004) [0x0000000000021002]              ( CPF_Const | CPF_Native | CPF_EditConst )
	class UObject*                                     Linker;                                           		// 0x0018 (0x0004) [0x0000000000821002]              ( CPF_Const | CPF_Native | CPF_EditConst | CPF_NoExport )
	struct FPointer                                    LinkerIndex;                                      		// 0x001C (0x0004) [0x0000000000821002]              ( CPF_Const | CPF_Native | CPF_EditConst | CPF_NoExport )
	int                                                ObjectInternalInteger;                            		// 0x0020 (0x0004) [0x0000000000821002]              ( CPF_Const | CPF_Native | CPF_EditConst | CPF_NoExport )
	int                                                NetIndex;                                         		// 0x0024 (0x0004) [0x0000000000821002]              ( CPF_Const | CPF_Native | CPF_EditConst | CPF_NoExport )
	class UObject*                                     Outer;                                            		// 0x0028 (0x0004) [0x0000000000021002]              ( CPF_Const | CPF_Native | CPF_EditConst )
	struct FName                                       Name;                                             		// 0x002C (0x0008) [0x0000000000021003]              ( CPF_Edit | CPF_Const | CPF_Native | CPF_EditConst )
	class UClass*                                      Class;                                            		// 0x0034 (0x0004) [0x0000000000021002]              ( CPF_Const | CPF_Native | CPF_EditConst )
	class UObject*                                     ObjectArchetype;                                  		// 0x0038 (0x0004) [0x0000000000021003]              ( CPF_Edit | CPF_Const | CPF_Native | CPF_EditConst )

private:
	static UClass* pClassPointer;

public:
	static TArray< UObject* >* GObjObjects(); 

	char* GetName(); 
	char* GetNameCPP(); 
	char* GetFullNameOld();

	void GetPathName(std::string& result);
	void AppendName(std::string& result);
	std::string GetFullName();

	template< class T > static T* FindObject ( const std::string& ObjectFullName ) 
	{ 
		while ( ! UObject::GObjObjects() ) 
			Sleep ( 100 ); 

		while ( ! FName::Names() ) 
			Sleep( 100 ); 

		for ( int i = 0; i < UObject::GObjObjects()->Count; ++i ) 
		{ 
			UObject* Object = UObject::GObjObjects()->Data[ i ]; 

			// skip no T class objects 
			if 
				( 
				! Object 
				||	! Object->IsA ( T::StaticClass() ) 
				) 
				continue; 

			// check 
			if (Object->GetFullName() == ObjectFullName) 
				return (T*) Object; 
		} 

		return NULL; 
	}

	bool IsA ( UClass* pClass ); 

	static UClass* StaticClass()
	{
		if ( ! pClassPointer )
			pClassPointer = (UClass*) UObject::GObjObjects()->Data[ 2 ];

		return pClassPointer;
	};

	int GetBuildChangelistNumber ( );
	int GetEngineVersion ( );

	// Virtual Functions
	virtual void VirtualFunction00 ( );																			// 0x00D70090 (0x00)
	virtual void VirtualFunction01 ( );																			// 0x00C63010 (0x04)
	virtual void VirtualFunction02 ( );																			// 0x00892230 (0x08)
	virtual void VirtualFunction03 ( );																			// 0x007DB380 (0x0C)
	virtual void VirtualFunction04 ( );																			// 0x00637C30 (0x10)
	virtual void VirtualFunction05 ( );																			// 0x00FB3390 (0x14)
	virtual void VirtualFunction06 ( );																			// 0x009670B0 (0x18)
	virtual void VirtualFunction07 ( );																			// 0x00A52920 (0x1C)
	virtual void VirtualFunction08 ( );																			// 0x00DF1450 (0x20)
	virtual void VirtualFunction09 ( );																			// 0x007F1B50 (0x24)
	virtual void VirtualFunction10 ( );																			// 0x00D70090 (0x28)
	virtual void VirtualFunction11 ( );																			// 0x00CB56F0 (0x2C)
	virtual void VirtualFunction12 ( );																			// 0x01075C30 (0x30)
	virtual void VirtualFunction13 ( );																			// 0x011E2420 (0x34)
	virtual void VirtualFunction14 ( );																			// 0x00D11930 (0x38)
	virtual void VirtualFunction15 ( );																			// 0x0053E170 (0x3C)
	virtual void VirtualFunction16 ( );																			// 0x00FB3390 (0x40)
	virtual void VirtualFunction17 ( );																			// 0x00B78400 (0x44)
	virtual void VirtualFunction18 ( );																			// 0x00EFDEF0 (0x48)
	virtual void VirtualFunction19 ( );																			// 0x00CE0970 (0x4C)
	virtual void VirtualFunction20 ( );																			// 0x008DAD80 (0x50)
	virtual void VirtualFunction21 ( );																			// 0x00831F00 (0x54)
	virtual void VirtualFunction22 ( );																			// 0x00935660 (0x58)
	virtual void VirtualFunction23 ( );																			// 0x00695390 (0x5C)
	virtual void VirtualFunction24 ( );																			// 0x00FB3390 (0x60)
	virtual void VirtualFunction25 ( );																			// 0x00FB3390 (0x64)
	virtual void VirtualFunction26 ( );																			// 0x00B7D170 (0x68)
	virtual void VirtualFunction27 ( );																			// 0x00935660 (0x6C)
	virtual void VirtualFunction28 ( );																			// 0x00695390 (0x70)
	virtual void VirtualFunction29 ( );																			// 0x00935660 (0x74)
	virtual void VirtualFunction30 ( );																			// 0x00695390 (0x78)
	virtual void VirtualFunction31 ( );																			// 0x00651670 (0x7C)
	virtual void VirtualFunction32 ( );																			// 0x00AB03D0 (0x80)
	virtual void VirtualFunction33 ( );																			// 0x00D792E0 (0x84)
	virtual void VirtualFunction34 ( );																			// 0x00FB3390 (0x88)
	virtual void VirtualFunction35 ( );																			// 0x00734D80 (0x8C)
	virtual void VirtualFunction36 ( );																			// 0x00430330 (0x90)
	virtual void VirtualFunction37 ( );																			// 0x009AC560 (0x94)
	virtual void VirtualFunction38 ( );																			// 0x00BCD940 (0x98)
	virtual void VirtualFunction39 ( );																			// 0x004C9A60 (0x9C)
	virtual void VirtualFunction40 ( );																			// 0x00F9BD10 (0xA0)
	virtual void VirtualFunction41 ( );																			// 0x00EA4350 (0xA4)
	virtual void VirtualFunction42 ( );																			// 0x00F9BD10 (0xA8)
	virtual void VirtualFunction43 ( );																			// 0x00665380 (0xAC)
	virtual void VirtualFunction44 ( );																			// 0x00665380 (0xB0)
	virtual void VirtualFunction45 ( );																			// 0x00FB3390 (0xB4)
	virtual void VirtualFunction46 ( );																			// 0x00F9BD10 (0xB8)
	virtual void VirtualFunction47 ( );																			// 0x01034CD0 (0xBC)
	virtual void VirtualFunction48 ( );																			// 0x00F43CB0 (0xC0)
	virtual void VirtualFunction49 ( );																			// 0x009BD180 (0xC4)
	virtual void VirtualFunction50 ( );																			// 0x00E71120 (0xC8)
	virtual void VirtualFunction51 ( );																			// 0x00637C30 (0xCC)
	virtual void VirtualFunction52 ( );																			// 0x00637C30 (0xD0)
	virtual void VirtualFunction53 ( );																			// 0x00665380 (0xD4)
	virtual void VirtualFunction54 ( );																			// 0x00575B90 (0xD8)
	virtual void VirtualFunction55 ( );																			// 0x0101CF50 (0xDC)
	virtual void VirtualFunction56 ( );																			// 0x00562170 (0xE0)
	virtual void VirtualFunction57 ( );																			// 0x00F9BD10 (0xE4)
	virtual void VirtualFunction58 ( );																			// 0x004C4660 (0xE8)
	virtual void VirtualFunction59 ( );																			// 0x01198490 (0xEC)
	virtual void VirtualFunction60 ( );																			// 0x010E8860 (0xF0)
	virtual void VirtualFunction61 ( );																			// 0x00F9BD10 (0xF4)
	virtual void VirtualFunction62 ( );																			// 0x007D5480 (0xF8)
	virtual void VirtualFunction63 ( );																			// 0x0107EE60 (0xFC)
	virtual void VirtualFunction64 ( );																			// 0x00FEA9F0 (0x100)
	virtual void VirtualFunction65 ( );																			// 0x00DB03E0 (0x104)
	virtual void VirtualFunction66 ( );																			// 0x00BBF1C0 (0x108)
	virtual void ProcessEvent ( class UFunction* pFunction, void* pParms, void* pResult = NULL );				// 0x0065C820 (0x10C)
};

// Class Core.Field
// 0x0004 (0x0040 - 0x003C)
class UField : public UObject
{
public:
	class UField*                                      Next;                                             		// NOT AUTO-GENERATED PROPERTY 

private:
	static UClass* pClassPointer;

public:
	static UClass* StaticClass()
	{
		if ( ! pClassPointer )
			pClassPointer = (UClass*) UObject::GObjObjects()->Data[ 66 ];

		return pClassPointer;
	};

};

// Class Core.Struct
// 0x004C (0x008C - 0x0040)
class UStruct : public UField
{
public:
	unsigned char                                      UnknownData00[ 0x8 ];                                    // NOT AUTO-GENERATED PROPERTY 
	class UField*                                      SuperField;                                              // NOT AUTO-GENERATED PROPERTY 
	class UField*                                      Children;                                                // NOT AUTO-GENERATED PROPERTY 
	unsigned short									   PropertySize;			                                // NOT AUTO-GENERATED PROPERTY 
	unsigned short									   UnknownData01;			                                // NOT AUTO-GENERATED PROPERTY 
    unsigned char									   UnknownData02[ 0x38 ];			                        // NOT AUTO-GENERATED PROPERTY 

private:
	static UClass* pClassPointer;

public:
	static UClass* StaticClass()
	{
		if ( ! pClassPointer )
			pClassPointer = (UClass*) UObject::GObjObjects()->Data[ 65 ];

		return pClassPointer;
	};

};

// Class Core.Function
// 0x0024 (0x00B0 - 0x008C)
class UFunction : public UStruct
{
public:
	unsigned long                                      FunctionFlags;                                            // NOT AUTO-GENERATED PROPERTY 
	unsigned short                                     iNative;                                                  // NOT AUTO-GENERATED PROPERTY 
	unsigned short                                     RepOffset;                                                // NOT AUTO-GENERATED PROPERTY 
	struct FName                                       FriendlyName;                                             // NOT AUTO-GENERATED PROPERTY 
	unsigned short                                     NumParms;                                                 // NOT AUTO-GENERATED PROPERTY 
	unsigned short                                     ParmsSize;                                                // NOT AUTO-GENERATED PROPERTY 
	unsigned long                                      ReturnValueOffset;                                        // NOT AUTO-GENERATED PROPERTY 
	unsigned char                                      UnknownData00[ 0x4 ];                                     // NOT AUTO-GENERATED PROPERTY 
	void*                                              Func;                                                     // NOT AUTO-GENERATED PROPERTY 

private:
	static UClass* pClassPointer;

public:
	static UClass* StaticClass()
	{
		if ( ! pClassPointer )
			pClassPointer = (UClass*) UObject::GObjObjects()->Data[ 70 ];

		return pClassPointer;
	};

};

// Class Core.State
// 0x0044 (0x00D0 - 0x008C)
class UState : public UStruct
{
public:
	unsigned char                                      UnknownData00[ 0x44 ];                            		// 0x008C (0x0044) MISSED OFFSET

private:
	static UClass* pClassPointer;

public:
	static UClass* StaticClass()
	{
		if ( ! pClassPointer )
			pClassPointer = (UClass*) UObject::GObjObjects()->Data[ 134 ];

		return pClassPointer;
	};

};

// Class Core.Class
// 0x0100 (0x01D0 - 0x00D0)
class UClass : public UState
{
public:
	unsigned char                                      UnknownData00[ 0x100 ];                           		// 0x00D0 (0x0100) MISSED OFFSET

private:
	static UClass* pClassPointer;

public:
	static UClass* StaticClass()
	{
		if ( ! pClassPointer )
			pClassPointer = (UClass*) UObject::GObjObjects()->Data[ 138 ];

		return pClassPointer;
	};

};

// Class Core.Package
// 0x00BC (0x00F8 - 0x003C)
class UPackage : public UObject
{
public:
	unsigned char                                      UnknownData00[ 0xBC ];                            		// 0x003C (0x00BC) MISSED OFFSET

private:
	static UClass* pClassPointer;

public:
	static UClass* StaticClass()
	{
		if ( ! pClassPointer )
			pClassPointer = (UClass*) UObject::GObjObjects()->Data[ 136 ];

		return pClassPointer;
	};
};

#ifdef _MSC_VER
	#pragma pack ( pop )
#endif