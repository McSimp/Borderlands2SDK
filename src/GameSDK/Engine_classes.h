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
# Classes
# ========================================================================================= #
*/

// Class Engine.Actor
// 0x014C (0x0188 - 0x003C)
class AActor : public UObject
{
public:
	unsigned char                                      UnknownData00[ 0x14C ];

	void LocalPlayerControllers ( class UClass* BaseClass, class APlayerController** PC );
};

// Class Engine.UIRoot
// 0x000C (0x0048 - 0x003C)
class UUIRoot : public UObject
{
public:
	unsigned char                                      UnknownData00[ 0xC ];
};

// Class Engine.Interaction
// 0x0030 (0x0078 - 0x0048)
class UInteraction : public UUIRoot
{
public:
	unsigned char                                      UnknownData00[ 0x30 ];
};

// Class Engine.Console
// 0x0158 (0x01D0 - 0x0078)
class UConsole : public UInteraction
{
public:
	unsigned char                                      UnknownData00[ 0xC ];             
	struct FName                                       ConsoleKey;                                       		// 0x0084 (0x0008) [0x0000000000044000]              ( CPF_Config | CPF_GlobalConfig )
	struct FName                                       TypeKey;                                          		// 0x008C (0x0008) [0x0000000000044000]              ( CPF_Config | CPF_GlobalConfig )
	int                                                MaxScrollbackSize;                                		// 0x0094 (0x0004) [0x0000000000044000]              ( CPF_Config | CPF_GlobalConfig )
	TArray< struct FString >                           Scrollback;                                       		// 0x0098 (0x000C) [0x0000000000400000]              ( CPF_NeedCtorLink )
	int                                                SBHead;                                           		// 0x00A4 (0x0004) [0x0000000000000000]              
	int                                                SBPos;                                            		// 0x00A8 (0x0004) [0x0000000000000000]              
	int                                                HistoryTop;                                       		// 0x00AC (0x0004) [0x0000000000004000]              ( CPF_Config )
	int                                                HistoryBot;                                       		// 0x00B0 (0x0004) [0x0000000000004000]              ( CPF_Config )
	int                                                HistoryCur;                                       		// 0x00B4 (0x0004) [0x0000000000004000]              ( CPF_Config )
	struct FString                                     History[ 0x10 ];                                  		// 0x00B8 (0x00C0) [0x0000000000404000]              ( CPF_Config | CPF_NeedCtorLink )
	unsigned long                                      bNavigatingHistory : 1;                           		// 0x0178 (0x0004) [0x0000000000002000] [0x00000001] ( CPF_Transient )
	unsigned long                                      bCaptureKeyInput : 1;                             		// 0x0178 (0x0004) [0x0000000000002000] [0x00000002] ( CPF_Transient )
	unsigned long                                      bCtrl : 1;                                        		// 0x0178 (0x0004) [0x0000000000000000] [0x00000004] 
	unsigned long                                      bEnableUI : 1;                                    		// 0x0178 (0x0004) [0x0000000000004000] [0x00000008] ( CPF_Config )
	unsigned long                                      bAutoCompleteLocked : 1;                          		// 0x0178 (0x0004) [0x0000000000002000] [0x00000010] ( CPF_Transient )
	unsigned long                                      bRequireCtrlToNavigateAutoComplete : 1;           		// 0x0178 (0x0004) [0x0000000000004000] [0x00000020] ( CPF_Config )
	unsigned long                                      bIsRuntimeAutoCompleteUpToDate : 1;               		// 0x0178 (0x0004) [0x0000000000002000] [0x00000040] ( CPF_Transient )
	struct FString                                     TypedStr;                                         		// 0x017C (0x000C) [0x0000000000400000]              ( CPF_NeedCtorLink )
	int                                                TypedStrPos;                                      		// 0x0188 (0x0004) [0x0000000000000000]              
	TArray< struct FAutoCompleteCommand >              ManualAutoCompleteList;                           		// 0x018C (0x000C) [0x0000000000404000]              ( CPF_Config | CPF_NeedCtorLink )
	TArray< struct FAutoCompleteCommand >              AutoCompleteList;                                 		// 0x0198 (0x000C) [0x0000000000402000]              ( CPF_Transient | CPF_NeedCtorLink )
	int                                                AutoCompleteIndex;                                		// 0x01A4 (0x0004) [0x0000000000002000]              ( CPF_Transient )
	struct FAutoCompleteNode                           AutoCompleteTree;                                 		// 0x01A8 (0x001C) [0x0000000000003000]              ( CPF_Native | CPF_Transient )
	TArray< int >                                      AutoCompleteIndices;                              		// 0x01C4 (0x000C) [0x0000000000402000]              ( CPF_Transient | CPF_NeedCtorLink )

private:
	static UClass* pClassPointer;

public:
	static UClass* StaticClass()
	{
		if ( ! pClassPointer )
			pClassPointer = (UClass*) UObject::GObjObjects()->Data[ 2443 ];

		return pClassPointer;
	};

	void UpdateCompleteIndices ( );
	void BuildRuntimeAutoCompleteList ( unsigned long bForce );
	void AppendInputText ( struct FString Text );
	bool ProcessControlKey ( struct FName Key, unsigned char Event );
	void FlushPlayerInput ( );
	bool InputChar ( int ControllerId, struct FString Unicode );
	bool InputKey ( int ControllerId, struct FName Key, unsigned char Event, float AmountDepressed, unsigned long bGamepad );
	void PostRender_Console ( class UCanvas* Canvas );
	void StartTyping ( struct FString Text );
	void eventOutputText ( struct FString Text );
	void OutputTextLine ( struct FString Text );
	void ClearOutput ( );
	void eventConsoleCommand ( struct FString Command );
	void ShippingConsoleCommand ( struct FString Command );
	void PurgeCommandFromHistory ( struct FString Command );
	void SetCursorPos ( int Position );
	void SetInputText ( struct FString Text );
	void Initialized ( );
};

// Class Engine.Controller
// 0x04E4 (0x066C - 0x0188)
class AController : public AActor
{
public:
	unsigned char                                      UnknownData00[ 0x4E4 ];
};

// Class Engine.PlayerController
// 0x0284 (0x08F0 - 0x066C)
class APlayerController : public AController
{
public:
	unsigned char                                      UnknownData00[ 0x284 ];

private:
	static UClass* pClassPointer;

public:
	static UClass* StaticClass()
	{
		if ( ! pClassPointer )
			pClassPointer = (UClass*) UObject::GObjObjects()->Data[ 491 ];

		return pClassPointer;
	};

	void IgnoreButtonInput ( unsigned long bNewButtonInput );
	void IgnoreLookInput ( unsigned long bNewLookInput );
	void IgnoreMoveInput ( unsigned long bNewMoveInput );
	bool IsLocalPlayerController ( );
};

// Class Engine.Canvas
// 0x005C (0x0098 - 0x003C)
class UCanvas : public UObject
{
public:
	void*		                                       Font;                                             		// 0x003C (0x0004) [0x0000000000000000]              
	float                                              OrgX;                                             		// 0x0040 (0x0004) [0x0000000000000000]              
	float                                              OrgY;                                             		// 0x0044 (0x0004) [0x0000000000000000]              
	float                                              ClipX;                                            		// 0x0048 (0x0004) [0x0000000000000000]              
	float                                              ClipY;                                            		// 0x004C (0x0004) [0x0000000000000000]              
	float                                              CurX;                                             		// 0x0050 (0x0004) [0x0000000000000002]              ( CPF_Const )
	float                                              CurY;                                             		// 0x0054 (0x0004) [0x0000000000000002]              ( CPF_Const )
	float                                              CurZ;                                             		// 0x0058 (0x0004) [0x0000000000000002]              ( CPF_Const )
	float                                              CurYL;                                            		// 0x005C (0x0004) [0x0000000000000000]              
	struct FColor                                      DrawColor;                                        		// 0x0060 (0x0004) [0x0000000000000000]              
	unsigned long                                      bCenter : 1;                                      		// 0x0064 (0x0004) [0x0000000000000000] [0x00000001] 
	unsigned long                                      bNoSmooth : 1;                                    		// 0x0064 (0x0004) [0x0000000000000000] [0x00000002] 
	int                                                SizeX;                                            		// 0x0068 (0x0004) [0x0000000000000002]              ( CPF_Const )
	int                                                SizeY;                                            		// 0x006C (0x0004) [0x0000000000000002]              ( CPF_Const )
	struct FPointer                                    Canvas;                                           		// 0x0070 (0x0004) [0x0000000000001002]              ( CPF_Const | CPF_Native )
	struct FPointer                                    SceneView;                                        		// 0x0074 (0x0004) [0x0000000000001002]              ( CPF_Const | CPF_Native )
	unsigned char                                      UnknownData00[ 0x8 ];                             		// 0x0078 (0x0008) MISSED OFFSET
	struct FPlane                                      ColorModulate;                                    		// 0x0080 (0x0010) [0x0000000000000000]              
	void*											   DefaultTexture;                                   		// 0x0090 (0x0004) [0x0000000000000000]              
	struct FColor                                      BGColor;                                          		// 0x0094 (0x0004) [0x0000000000000000]              

private:
	static UClass* pClassPointer;

public:
	static UClass* StaticClass()
	{
		if ( ! pClassPointer )
			pClassPointer = (UClass*) UObject::GObjObjects()->Data[ 477 ];

		return pClassPointer;
	};

};