/*
#############################################################################################
# Borderlands 2 (1.0.35.4705) SDK
# Generated with TheFeckless UE3 SDK Generator v1.4_Beta-Rev.51
# Credits: uNrEaL, Tamimego, SystemFiles, R00T88, _silencer, the1domo, K@N@VEL
# Thanks: HOOAH07, lowHertz
# Forums: www.uc-forum.com, www.gamedeception.net
#############################################################################################
*/
#include "GameSDK/GameSDK.h"

#ifdef _MSC_VER
	#pragma pack ( push, 0x4 )
#endif

/*
# ========================================================================================= #
# Global Static Class Pointers
# ========================================================================================= #
*/

UClass* UObject::pClassPointer = NULL;
UClass* UField::pClassPointer = NULL;
UClass* UStruct::pClassPointer = NULL;
UClass* UFunction::pClassPointer = NULL;
UClass* UState::pClassPointer = NULL;
UClass* UClass::pClassPointer = NULL;

/*
# ========================================================================================= #
# Basic Functions
# ========================================================================================= #
*/

TArray< UObject* >* UObject::GObjObjects() 
{ 
	TArray< UObject* >* ObjectArray = (TArray< UObject* >*) BL2SDK::pGObjects; 
	return ObjectArray; 
} 

char* UObject::GetName() 
{ 
	static char cOutBuffer[ 256 ]; 
	ZeroMemory( cOutBuffer, 256 );

	sprintf_s ( cOutBuffer, "%s", this->Name.GetName() ); 

	return cOutBuffer; 
} 

char* UObject::GetNameCPP() 
{ 
	static char cOutBuffer[ 256 ]; 
	ZeroMemory( cOutBuffer, 256 );

	if ( this->IsA ( UClass::StaticClass() ) ) 
	{ 
		UClass* pClass = (UClass*) this; 
		while ( pClass ) 
		{ 
			if ( ! strcmp ( pClass->GetName(), "Actor" ) ) 
			{ 
				strcpy_s ( cOutBuffer, "A" ); 
				break; 
			} 
			else if ( ! strcmp ( pClass->GetName(), "Object" ) ) 
			{ 
				strcpy_s ( cOutBuffer, "U" ); 
				break; 
			} 

			pClass = (UClass*) pClass->SuperField; 
		} 
	} 
	else 
	{ 
		strcpy_s ( cOutBuffer, "F" ); 
	} 

	strcat_s ( cOutBuffer, this->GetName() ); 

	return cOutBuffer; 
} 

char* UObject::GetFullName() 
{ 
	if ( this->Class && this->Outer ) 
	{ 
		static char cOutBuffer[ 256 ]; 
		ZeroMemory( cOutBuffer, 256 );

		if ( this->Outer->Outer ) 
		{ 
			strcpy_s ( cOutBuffer, this->Class->GetName() ); 
			strcat_s ( cOutBuffer, " " ); 
			strcat_s ( cOutBuffer, this->Outer->Outer->GetName() ); 
			strcat_s ( cOutBuffer, "." ); 
			strcat_s ( cOutBuffer, this->Outer->GetName() ); 
			strcat_s ( cOutBuffer, "." ); 
			strcat_s ( cOutBuffer, this->GetName() ); 
		} 
		else 
		{ 
			strcpy_s ( cOutBuffer, this->Class->GetName() ); 
			strcat_s ( cOutBuffer, " " ); 
			strcat_s ( cOutBuffer, this->Outer->GetName() ); 
			strcat_s ( cOutBuffer, "." ); 
			strcat_s ( cOutBuffer, this->GetName() ); 
		} 

		return cOutBuffer; 
	} 

	return "(null)"; 
} 

UClass* UObject::FindClass ( char* ClassFullName ) 
{ 
	while ( ! UObject::GObjObjects() ) 
		Sleep ( 100 ); 

	while ( ! FName::Names() ) 
		Sleep ( 100 ); 

	for ( int i = 0; i < UObject::GObjObjects()->Count; ++i ) 
	{ 
		UObject* Object = UObject::GObjObjects()->Data[ i ]; 

		if ( ! Object ) 
			continue; 

		if ( ! _stricmp ( Object->GetFullName(), ClassFullName ) ) 
			return (UClass*) Object; 
	} 

	return NULL; 
} 

bool UObject::IsA ( UClass* pClass ) 
{ 
	for ( UClass* SuperClass = this->Class; SuperClass; SuperClass = ( UClass* ) SuperClass->SuperField ) 
	{ 
		if ( SuperClass == pClass ) 
			return true; 
	} 

	return false; 
} 

/*
# ========================================================================================= #
# Functions
# ========================================================================================= #
*/

// Function Core.Object.GetBuildChangelistNumber
// [0x00020401] ( FUNC_Final | FUNC_Native )
// Parameters infos:
// int                            ReturnValue                    ( CPF_Parm | CPF_OutParm | CPF_ReturnParm )

int UObject::GetBuildChangelistNumber ( )
{
	static UFunction* pFnGetBuildChangelistNumber = NULL;

	if ( ! pFnGetBuildChangelistNumber )
		pFnGetBuildChangelistNumber = (UFunction*) UObject::GObjObjects()->Data[ 5355 ];

	UObject_execGetBuildChangelistNumber_Parms GetBuildChangelistNumber_Parms;

	pFnGetBuildChangelistNumber->FunctionFlags |= ~0x400;

	this->ProcessEvent ( pFnGetBuildChangelistNumber, &GetBuildChangelistNumber_Parms, NULL );

	pFnGetBuildChangelistNumber->FunctionFlags |= 0x400;

	return GetBuildChangelistNumber_Parms.ReturnValue;
};

// Function Core.Object.GetEngineVersion
// [0x00020401] ( FUNC_Final | FUNC_Native )
// Parameters infos:
// int                            ReturnValue                    ( CPF_Parm | CPF_OutParm | CPF_ReturnParm )

int UObject::GetEngineVersion ( )
{
	static UFunction* pFnGetEngineVersion = NULL;

	if ( ! pFnGetEngineVersion )
		pFnGetEngineVersion = (UFunction*) UObject::GObjObjects()->Data[ 5359 ];

	UObject_execGetEngineVersion_Parms GetEngineVersion_Parms;

	pFnGetEngineVersion->FunctionFlags |= ~0x400;

	this->ProcessEvent ( pFnGetEngineVersion, &GetEngineVersion_Parms, NULL );

	pFnGetEngineVersion->FunctionFlags |= 0x400;

	return GetEngineVersion_Parms.ReturnValue;
};

#ifdef _MSC_VER
	#pragma pack ( pop )
#endif