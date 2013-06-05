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

/*
# ========================================================================================= #
# Function Structs
# ========================================================================================= #
*/

// Function Engine.Console.ConsoleCommand
// [0x00020802] ( FUNC_Event )
struct UConsole_eventConsoleCommand_Parms
{
	struct FString                                     Command;                                          		// 0x0000 (0x000C) [0x0000000000400080]              ( CPF_Parm | CPF_NeedCtorLink )
};

// Function Engine.Console.OutputText
// [0x00020802] ( FUNC_Event )
struct UConsole_eventOutputText_Parms
{
	struct FString                                     Text;                                             		// 0x0000 (0x000C) [0x0000000000400880]              ( CPF_Parm | CPF_CoerceParm | CPF_NeedCtorLink )
	// struct FString                                  RemainingText;                                    		// 0x000C (0x000C) [0x0000000000400000]              ( CPF_NeedCtorLink )
};

// Function Engine.PlayerController.IgnoreButtonInput
// [0x00020002] 
struct APlayerController_execIgnoreButtonInput_Parms
{
	unsigned long                                      bNewButtonInput : 1;                              		// 0x0000 (0x0004) [0x0000000000000080] [0x00000001] ( CPF_Parm )
};

// Function Engine.PlayerController.IgnoreLookInput
// [0x00020002] 
struct APlayerController_execIgnoreLookInput_Parms
{
	unsigned long                                      bNewLookInput : 1;                                		// 0x0000 (0x0004) [0x0000000000000080] [0x00000001] ( CPF_Parm )
};

// Function Engine.PlayerController.IgnoreMoveInput
// [0x00020002] 
struct APlayerController_execIgnoreMoveInput_Parms
{
	unsigned long                                      bNewMoveInput : 1;                                		// 0x0000 (0x0004) [0x0000000000000080] [0x00000001] ( CPF_Parm )
};

// Function Engine.GameViewportClient.PostRender
// [0x00020802] ( FUNC_Event )
struct UGameViewportClient_eventPostRender_Parms
{
	class UCanvas*                                     Canvas;                                           		// 0x0000 (0x0004) [0x0000000000000080]              ( CPF_Parm )
};

#ifdef _MSC_VER
	#pragma pack ( pop )
#endif