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
# Script Structs
# ========================================================================================= #
*/

// ScriptStruct Engine.Console.AutoCompleteNode
// 0x001C
struct FAutoCompleteNode
{
	int                                                IndexChar;                                        		// 0x0000 (0x0004) [0x0000000000000000]              
	TArray< int >                                      AutoCompleteListIndices;                          		// 0x0004 (0x000C) [0x0000000000500000]              ( CPF_NeedCtorLink )
	TArray< struct FPointer >                          ChildNodes;                                       		// 0x0010 (0x000C) [0x0000000000500000]              ( CPF_NeedCtorLink )
};

#ifdef _MSC_VER
	#pragma pack ( pop )
#endif