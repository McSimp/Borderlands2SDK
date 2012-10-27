#ifndef GAMESDK_H
#define GAMESDK_H

#define MOV_OP_OFFSET			2

#define GObjects_Pattern		"\x8B\x0D\x00\x00\x00\x00\x8B\x04\xB1\x8B\x40\x08"
#define GObjects_Mask			"xx????xxxxxx"

#define GNames_Pattern			"\x8B\x0D\x00\x00\x00\x00\x83\x3C\x81\x00\x74"
#define GNames_Mask				"xx????xxxxx"

#define ProcessEvent_Pattern	"\x55\x8B\xEC\x6A\xFF\x68\x00\x00\x00\x00\x64\xA1\x00\x00\x00\x00\x50\x83\xEC\x50\xA1\x00\x00\x00\x00\x33\xC5\x89\x45\xF0\x53\x56\x57\x50\x8D\x45\xF4\x64\xA3\x00\x00\x00\x00\x8B\xF1\x89\x75\xEC"
#define ProcessEvent_Mask		"xxxxxx????xx????xxxxx????xxxxxxxxxxxxxx????xxxxx"

#define CrashHandler_Pattern	"\x55\x8B\xEC\x6A\xFF\x68\x00\x00\x00\x00\x64\xA1\x00\x00\x00\x00\x50\x81\xEC\x00\x00\x00\x00\xA1\x00\x00\x00\x00\x33\xC5\x89\x45\xF0\x53\x56\x57\x50\x8D\x45\xF4\x64\xA3\x00\x00\x00\x00\x83\x3D\x00\x00\x00\x00\x00\x8B\x7D\x0C"
#define CrashHandler_Mask		"xxxxxx????xx????xxx????x????xxxxxxxxxxxxxx????xx?????xxx"

namespace BL2SDK
{
	unsigned long GNames();
	unsigned long GObjects();
}

#include "GameSDK/GameDefines.h"
#include "GameSDK/Core_structs.h"
#include "GameSDK/Core_classes.h"
#include "GameSDK/Core_f_structs.h"
#include "GameSDK/Engine_structs.h"
#include "GameSDK/Engine_classes.h"
#include "GameSDK/Engine_f_structs.h"
#include "GameSDK/GameFramework_structs.h"
#include "GameSDK/GameFramework_classes.h"
#include "GameSDK/GameFramework_f_structs.h"
#include "GameSDK/GFxUI_structs.h"
#include "GameSDK/GFxUI_classes.h"
#include "GameSDK/GFxUI_f_structs.h"
#include "GameSDK/GearboxFramework_structs.h"
#include "GameSDK/GearboxFramework_classes.h"
#include "GameSDK/GearboxFramework_f_structs.h"
#include "GameSDK/IpDrv_structs.h"
#include "GameSDK/IpDrv_classes.h"
#include "GameSDK/IpDrv_f_structs.h"
#include "GameSDK/XAudio2_structs.h"
#include "GameSDK/XAudio2_classes.h"
#include "GameSDK/XAudio2_f_structs.h"
#include "GameSDK/AkAudio_structs.h"
#include "GameSDK/AkAudio_classes.h"
#include "GameSDK/AkAudio_f_structs.h"
#include "GameSDK/WinDrv_structs.h"
#include "GameSDK/WinDrv_classes.h"
#include "GameSDK/WinDrv_f_structs.h"
#include "GameSDK/OnlineSubsystemSteamworks_structs.h"
#include "GameSDK/OnlineSubsystemSteamworks_classes.h"
#include "GameSDK/OnlineSubsystemSteamworks_f_structs.h"
#include "GameSDK/WillowGame_structs.h"
#include "GameSDK/WillowGame_classes.h"
#include "GameSDK/WillowGame_f_structs.h"

#endif