#include "LuaInterface/CLuaInterface.h"
#include "BL2SDK/Logging.h"
#include "BL2SDK/Settings.h"
#include "BL2SDK/Util.h"
#include "BL2SDK/BL2SDK.h"
#include <algorithm>

#include "LuaInterface/LuaFileLib.h"

#define CRYPTOPP_DEFAULT_NO_DLL
#include "cryptopp/c5/dll.h"
#include "cryptopp/c5/sha.h"
#include "cryptopp/c5/files.h"

#include "generated/LuaHashes.h"

#define luaL_dofile_nobc(L, fn) \
	(luaL_loadfilex(L, fn, "t") || lua_pcall(L, 0, LUA_MULTRET, 0))

#define luaL_dostring_nobc(L, s) \
	(luaL_loadbufferx(L, s, strlen(s), s, "t") || lua_pcall(L, 0, LUA_MULTRET, 0))

#define SET_POINTER(L, k, v) lua_pushstring(L, k); lua_pushlightuserdata(L, (void*)v); lua_settable(L, -3);
#define SET_NUMBER(L, k, v) lua_pushstring(L, k); lua_pushnumber(L, v); lua_settable(L, -3);
#define SET_STRING(L, k, v) lua_pushstring(L, k); lua_pushstring(L, v); lua_settable(L, -3);
#define SET_NIL(L, k) lua_pushstring(L, k); lua_pushnil(L); lua_settable(L, -3);

static int luabl2_dofile(lua_State* L, const char* path)
{
	int status = luaL_dofile_nobc(L, path);
	if(status != 0)
	{
		Logging::LogF("[Lua] ERROR: DoFile failed to run file - %s\n", lua_tostring(L, -1));
		lua_pop(L, 1);
	}
	return status;
}

static int luabl2_print(lua_State* L) 
{
	int n = lua_gettop(L);  /* number of arguments */
	lua_getglobal(L, "tostring");

	for(int i = 1; i <= n; i++)
	{
		const char* s;
		lua_pushvalue(L, -1);  /* function to be called */
		lua_pushvalue(L, i);   /* value to print */
		lua_call(L, 1, 1);
		size_t len;
		s = lua_tolstring(L, -1, &len); /* get result */
		if(s == NULL)
			return luaL_error(L, LUA_QL("tostring") " must return a string to " LUA_QL("print"));
		if(i>1) 
			Logging::Log("\t");
		Logging::Log(s, len);
		lua_pop(L, 1);  /* pop result */
	}

	Logging::Log("\n");
	return 0;
}

static int luabl2_include(lua_State* L) 
{
	lua_Debug dbg1;
	lua_getstack(L, 1, &dbg1);
	lua_getinfo(L, "f", &dbg1);
	lua_Debug dbg2;
	lua_getinfo(L, ">S", &dbg2);

	std::string source = dbg2.source; // eg: @D:\dev\bl\Borderlands2SDK\bin\Debug\lua\test.lua
	std::string filename = luaL_checkstring(L, 1);
	std::replace(filename.begin(), filename.end(), '/', '\\');
	std::string path = source.substr(1, source.find_last_of("\\/")) + filename; // Cuts off the @ at the start of the path and removes the filename
	
	luabl2_dofile(L, path.c_str());

	return 0;
}

static const luaL_Reg base_funcs[] = {
	{"print", luabl2_print},
	{"include", luabl2_include},
	{NULL, NULL}
};

static void StackDump(lua_State* L)
{
	int i = lua_gettop(L);
	Logging::Log(" ----------------  Stack Dump ----------------\n" );
	while(i) 
	{
		int t = lua_type(L, i);
		switch (t) {
		case LUA_TSTRING:
			Logging::LogF("%d:'%s'\n", i, lua_tostring(L, i));
			break;
		case LUA_TBOOLEAN:
			Logging::LogF("%d: %s\n", i, lua_toboolean(L, i) ? "true" : "false");
			break;
		case LUA_TNUMBER:
			Logging::LogF("%d: %g\n", i, lua_tonumber(L, i));
			break;
		default: 
			Logging::LogF("%d: %s\n", i, lua_typename(L, t));
			break;
		}
		i--;
	}
	Logging::Log("--------------- Stack Dump Finished ---------------\n" );
}

CLuaInterface::CLuaInterface()
{
	InitializeState();
}

CLuaInterface::~CLuaInterface()
{
	CleanupState();
}

void CLuaInterface::InitializeState()
{
	m_pState = luaL_newstate();

	luaL_openlibs(m_pState);

	// Add the file library
	luaopen_file(m_pState);

	lua_pushvalue(m_pState, LUA_GLOBALSINDEX);
	luaL_register(m_pState, NULL, base_funcs);

	// Let's delete the things we don't want
	SET_NIL(m_pState, "load");
	SET_NIL(m_pState, "loadfile");
	SET_NIL(m_pState, "loadstring");
	SET_NIL(m_pState, "dofile");
	lua_pop(m_pState, 1); // pop global table

	// Cleanup os table
	lua_getfield(m_pState, LUA_GLOBALSINDEX, LUA_OSLIBNAME);
	SET_NIL(m_pState, "execute");
	SET_NIL(m_pState, "rename");
	SET_NIL(m_pState, "setlocale");
	SET_NIL(m_pState, "getenv");
	SET_NIL(m_pState, "remove");
	SET_NIL(m_pState, "exit");
	SET_NIL(m_pState, "tmpname");
	lua_pop(m_pState, 1); // pop os table

	// Cleanup package table
	lua_getfield(m_pState, LUA_GLOBALSINDEX, LUA_LOADLIBNAME);
	SET_NIL(m_pState, "loadlib");
	SET_NIL(m_pState, "searchpath");
	lua_pop(m_pState, 1); // pop package table

	// Cleanup string table
	lua_getfield(m_pState, LUA_GLOBALSINDEX, LUA_STRLIBNAME);
	SET_NIL(m_pState, "dump");
	lua_pop(m_pState, 1); // pop string table

	SetSDKValues();
	SetPaths();
}

void CLuaInterface::CleanupState()
{
	lua_close(m_pState);
}

bool CLuaInterface::InitializeModules()
{
	if(!VerifyLuaFiles())
	{
		// TODO: Do something about this
	}

	if(DoFile("includes\\init.lua") != 0) // Means it failed, TODO: More obvious warning for this
	{
		Logging::Log("[Lua] Failed to initialize Lua modules\n");
		return false;
	}

	// Check to see if we set the global flag to reset the Lua state
	lua_getfield(m_pState, LUA_GLOBALSINDEX, "RESET_FLAG");
	if(!lua_isnil(m_pState, -1) && lua_toboolean(m_pState, -1) == 1)
	{
		CleanupState();
		InitializeState();
		return InitializeModules();
	}
	else
	{
		Logging::Log("[Lua] Lua initialized (" LUA_VERSION ")\n");
		return true;
	}
}

bool CLuaInterface::VerifyLuaFiles()
{
	for(int i = 0; i < LuaHashes::Count; i++)
	{
		if(!CheckHash(LuaHashes::HashList + i))
		{
			return false;
		}
	}

	return true;
}

bool CLuaInterface::CheckHash(FileHash* fileHash)
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

void CLuaInterface::SetSDKValues()
{
	lua_newtable(m_pState);

	SET_POINTER(m_pState, "GNames", BL2SDK::pGNames);
	SET_POINTER(m_pState, "GObjects", BL2SDK::pGObjects);
	SET_POINTER(m_pState, "ProcessEvent", BL2SDK::pProcessEvent);
	SET_POINTER(m_pState, "GObjHash", BL2SDK::pGObjHash);
	SET_POINTER(m_pState, "GCRCTable", BL2SDK::pGCRCTable);
	SET_POINTER(m_pState, "NameHash", BL2SDK::pNameHash);
	SET_POINTER(m_pState, "FrameStep", BL2SDK::pFrameStep);
	SET_POINTER(m_pState, "CallFunction", BL2SDK::pCallFunction);

	SET_NUMBER(m_pState, "engineVersion", BL2SDK::EngineVersion);
	SET_NUMBER(m_pState, "changeListNumber", BL2SDK::ChangelistNumber);

	lua_setfield(m_pState, LUA_GLOBALSINDEX, "bl2sdk");
}

void CLuaInterface::SetPaths()
{
	// Set path to Lua folder for require(), without trailing slash
	m_luaPath = Util::Narrow(Settings::GetBinFile(L"lua"));
	Logging::LogF("[Lua] Lua Path = %s\n", m_luaPath.c_str());

	lua_getfield(m_pState, LUA_GLOBALSINDEX, LUA_LOADLIBNAME);
	lua_getfield(m_pState, -1, "path");
	const char* pkgPath = lua_tostring(m_pState, -1);
	lua_pop(m_pState, 1); // pop path string

	std::string newPath = Util::Format("%s\\includes\\modules\\?.lua;%s", m_luaPath.c_str(), pkgPath);
	SET_STRING(m_pState, "path", newPath.c_str());
	lua_pop(m_pState, 1); // pop table
}

int CLuaInterface::RunString(const char* string)
{
	int error = luaL_dostring_nobc(m_pState, string);
	if(error != 0)
	{
		Logging::LogF("[Lua] ERROR: RunString failed - %s\n", lua_tostring(m_pState, -1));
		lua_pop(m_pState, 1);
	}
	return error;
}

int CLuaInterface::DoFile(const std::string& filename)
{
	return DoFileAbsolute(Util::Format("%s\\%s", m_luaPath.c_str(), filename.c_str()));
}

int CLuaInterface::DoFileAbsolute(const std::string& path)
{
	return luabl2_dofile(m_pState, path.c_str());
}
