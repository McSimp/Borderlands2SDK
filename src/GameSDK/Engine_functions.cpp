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

UClass* UConsole::pClassPointer = NULL;
UClass* APlayerController::pClassPointer = NULL;
UClass* UCanvas::pClassPointer = NULL;

/*
# ========================================================================================= #
# Functions
# ========================================================================================= #
*/

// Function Engine.Console.ConsoleCommand
// [0x00020802] ( FUNC_Event )
// Parameters infos:
// struct FString                 Command                        ( CPF_Parm | CPF_NeedCtorLink )

void UConsole::eventConsoleCommand ( struct FString Command )
{
	static UFunction* pFnConsoleCommand = NULL;

	if ( ! pFnConsoleCommand )
		pFnConsoleCommand = UObject::FindObject<UFunction>("Function Engine.Console.ConsoleCommand");

	UConsole_eventConsoleCommand_Parms ConsoleCommand_Parms;
	memcpy ( &ConsoleCommand_Parms.Command, &Command, 0xC );

	this->ProcessEvent ( pFnConsoleCommand, &ConsoleCommand_Parms, NULL );
};

// Function Engine.Console.OutputText
// [0x00020802] ( FUNC_Event )
// Parameters infos:
// struct FString                 Text                           ( CPF_Parm | CPF_CoerceParm | CPF_NeedCtorLink )

void UConsole::eventOutputText ( struct FString Text )
{
	static UFunction* pFnOutputText = NULL;

	if ( ! pFnOutputText )
		pFnOutputText = UObject::FindObject<UFunction>("Function Engine.Console.OutputText");

	UConsole_eventOutputText_Parms OutputText_Parms;
	memcpy ( &OutputText_Parms.Text, &Text, 0xC );

	this->ProcessEvent ( pFnOutputText, &OutputText_Parms, NULL );
};

// Function Engine.PlayerController.IgnoreButtonInput
// [0x00020002] 
// Parameters infos:
// unsigned long                  bNewButtonInput                ( CPF_Parm )

void APlayerController::IgnoreButtonInput ( unsigned long bNewButtonInput )
{
	static UFunction* pFnIgnoreButtonInput = NULL;

	if ( ! pFnIgnoreButtonInput )
		pFnIgnoreButtonInput = UObject::FindObject<UFunction>("Function Engine.PlayerController.IgnoreButtonInput");

	APlayerController_execIgnoreButtonInput_Parms IgnoreButtonInput_Parms;
	IgnoreButtonInput_Parms.bNewButtonInput = bNewButtonInput;

	this->ProcessEvent ( pFnIgnoreButtonInput, &IgnoreButtonInput_Parms, NULL );
};

// Function Engine.PlayerController.IgnoreLookInput
// [0x00020002] 
// Parameters infos:
// unsigned long                  bNewLookInput                  ( CPF_Parm )

void APlayerController::IgnoreLookInput ( unsigned long bNewLookInput )
{
	static UFunction* pFnIgnoreLookInput = NULL;

	if ( ! pFnIgnoreLookInput )
		pFnIgnoreLookInput = UObject::FindObject<UFunction>("Function Engine.PlayerController.IgnoreLookInput");

	APlayerController_execIgnoreLookInput_Parms IgnoreLookInput_Parms;
	IgnoreLookInput_Parms.bNewLookInput = bNewLookInput;

	this->ProcessEvent ( pFnIgnoreLookInput, &IgnoreLookInput_Parms, NULL );
};

// Function Engine.PlayerController.IgnoreMoveInput
// [0x00020002] 
// Parameters infos:
// unsigned long                  bNewMoveInput                  ( CPF_Parm )

void APlayerController::IgnoreMoveInput ( unsigned long bNewMoveInput )
{
	static UFunction* pFnIgnoreMoveInput = NULL;

	if ( ! pFnIgnoreMoveInput )
		pFnIgnoreMoveInput = UObject::FindObject<UFunction>("Function Engine.PlayerController.IgnoreMoveInput");

	APlayerController_execIgnoreMoveInput_Parms IgnoreMoveInput_Parms;
	IgnoreMoveInput_Parms.bNewMoveInput = bNewMoveInput;

	this->ProcessEvent ( pFnIgnoreMoveInput, &IgnoreMoveInput_Parms, NULL );
};