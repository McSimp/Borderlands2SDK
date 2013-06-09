#include "LuaInterface/LuaManager.h"
#include "BL2SDK/Logging.h"
#include "Commands/ConCommand.h"

#define CRYPTOPP_DEFAULT_NO_DLL
#include "cryptopp/dll.h"
#include "cryptopp/sha.h"
#include "cryptopp/files.h"

#include "generated/LuaHashes.h"

namespace LuaManager
{
	CLuaInterface* g_Lua;
	bool resetOnCompletion = false;

	bool CheckHash(FileHash* fileHash)
	{
		CryptoPP::SHA256 hash;
		std::string result;

		std::wstring path = Settings::GetLuaFile(fileHash->file);

		// Check the file exists
		DWORD fileAttrib = GetFileAttributes(path.c_str());
		if(fileAttrib == INVALID_FILE_ATTRIBUTES || (fileAttrib & FILE_ATTRIBUTE_DIRECTORY))
		{
			Logging::LogF("[Lua] FILE DOES NOT EXIST: File = %ls\n", fileHash->file);
			return false;
		}

		// Calculate hash
		CryptoPP::FileSource(path.c_str(), true,
			new CryptoPP::HashFilter(hash, 
				new CryptoPP::HexEncoder(
					new CryptoPP::StringSink(result), true)));

		// Compare hashes
		if(result != fileHash->hash)
		{
			Logging::LogF("[Lua] HASH CHECK FAILED: File = %ls, Hash = %s\n", fileHash->file, result.c_str());
			return false;
		}

		return true;
	}

	bool VerifyLuaFiles()
	{
		for(int i = 0; i < NumLuaHashes; i++)
		{
			if(!CheckHash(LuaHashes + i))
			{
				return false;
			}
		}

		return true;
	}

	void Initialize()
	{
		// Create state and interface
		g_Lua = new CLuaInterface();

		if(!VerifyLuaFiles())
		{
			// TODO: Do something about this
		}

		// Setup everything on the Lua side
		if(g_Lua->DoFile("includes\\init.lua") != 0) // Means it failed, weird right
		{
			Logging::Log("[Lua] Failed to initialize Lua modules\n");
		}

		if(resetOnCompletion)
		{
			resetOnCompletion = false;
			LuaManager::Shutdown();
			LuaManager::Initialize();
		}
		else
		{
			Logging::Log("[Lua] Lua initialized (" LUA_VERSION ")\n");
		}
	}

	void Shutdown()
	{
		delete g_Lua;
		g_Lua = NULL;
	}

	extern "C" __declspec(dllexport) void LUAFUNC_SetResetLuaFlag()
	{
		resetOnCompletion = true;
	}
}

CON_COMMAND(ResetLua)
{
	LuaManager::Shutdown();
	LuaManager::Initialize();
}
