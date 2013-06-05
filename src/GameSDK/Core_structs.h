// ScriptStruct Core.Object.Vector
// 0x000C
struct FVector
{
	float                                              X;                                                		// 0x0000 (0x0004) [0x0000000000000001]              ( CPF_Edit )
	float                                              Y;                                                		// 0x0004 (0x0004) [0x0000000000000001]              ( CPF_Edit )
	float                                              Z;                                                		// 0x0008 (0x0004) [0x0000000000000001]              ( CPF_Edit )
};

// ScriptStruct Core.Object.Plane
// 0x0004(0x0010 - 0x000C)
struct FPlane : FVector
{
	float                                              W;                                                		// 0x000C (0x0004) [0x0000000000000001]              ( CPF_Edit )
};

// ScriptStruct Core.Object.Color
// 0x0004
struct FColor
{
	unsigned char                                      B;                                                		// 0x0000 (0x0001) [0x0000000000000001]              ( CPF_Edit )
	unsigned char                                      G;                                                		// 0x0001 (0x0001) [0x0000000000000001]              ( CPF_Edit )
	unsigned char                                      R;                                                		// 0x0002 (0x0001) [0x0000000000000001]              ( CPF_Edit )
	unsigned char                                      A;                                                		// 0x0003 (0x0001) [0x0000000000000001]              ( CPF_Edit )
};

// ScriptStruct Core.Object.Pointer
// 0x0004
struct FPointer
{
	int                                                Dummy;                                            		// 0x0000 (0x0004) [0x0000000000001002]              ( CPF_Const | CPF_Native )
};

// ScriptStruct Core.Object.QWord
// 0x0008
struct FQWord
{
	int                                                A;                                                		// 0x0000 (0x0004) [0x0000000000001002]              ( CPF_Const | CPF_Native )
	int                                                B;                                                		// 0x0004 (0x0004) [0x0000000000001002]              ( CPF_Const | CPF_Native )
};