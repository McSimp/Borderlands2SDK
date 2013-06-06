#include "LuaInterface/LuaManager.h"
#include "BL2SDK/Logging.h"
#include "Commands/ConCommand.h"

namespace LuaManager
{
	CLuaInterface* g_Lua;
	bool resetOnCompletion = false;

	void Initialize()
	{
		// Create state and interface
		g_Lua = new CLuaInterface();

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
