// Probably best not to look in here, the horrible-ness might blind you

#include "LuaInterface/LuaFileLib.h"
#include "BL2SDK/Settings.h"
#include "BL2SDK/Util.h"
#include "BL2SDK/Logging.h"
#include <string>
#include <algorithm>

#define WIN32_LEAN_AND_MEAN
#include <Windows.h>

#define LUA_WINFILEHANDLE "HANDLE"
#define ToHandleP(L) ((HANDLE*)luaL_checkudata(L, 1, LUA_WINFILEHANDLE))

static HANDLE* file_createhandleud(lua_State* L)
{
	HANDLE* ph = (HANDLE*)lua_newuserdata(L, sizeof(HANDLE));
	*ph = NULL; // default invalid handle
	luaL_getmetatable(L, LUA_WINFILEHANDLE);
	lua_setmetatable(L, -2);
	return ph;
}

static HANDLE ToHandleSafe(lua_State* L)
{
	HANDLE* ph = ToHandleP(L);
	if(*ph == NULL)
		luaL_error(L, "attempt to use a closed file");
	return *ph;
}

static int file_createdir(lua_State* L)
{
	size_t len = 0;
	const char* path = luaL_checklstring(L, 1, &len);
	if(len == 0)
	{
		return luaL_argerror(L, 1, "Path was empty");
	}

	std::string strPath = path;

	// Fix slashes
	std::replace(strPath.begin(), strPath.end(), '/', '\\');

	// Check for up directory
	if(strPath.find("..") != std::string::npos) 
	{
		return luaL_argerror(L, 1, "Path was invalid");
	}

	std::wstring wstrPath = Util::Widen(strPath);
	std::wstring absPath = Settings::GetLuaFile(wstrPath);

	if(!CreateDirectory(absPath.c_str(), NULL))
	{
		return luaL_error(L, "Failed to create directory (GetLastError = %d)", GetLastError());
	}

	return 0;
}

static int file_isdir(lua_State* L)
{
	const char* filename = luaL_checkstring(L, 1);
	std::wstring wstrPath = Util::Widen(filename);
	std::wstring absPath = Settings::GetLuaFile(wstrPath);

	DWORD dwAttrib = GetFileAttributes(absPath.c_str());
	lua_pushboolean(L, (dwAttrib != INVALID_FILE_ATTRIBUTES && (dwAttrib & FILE_ATTRIBUTE_DIRECTORY)));
	
	return 1;
}

static int file_exists(lua_State* L)
{
	const char* filename = luaL_checkstring(L, 1);
	std::wstring wstrPath = Util::Widen(filename);
	std::wstring absPath = Settings::GetLuaFile(wstrPath);

	DWORD dwAttrib = GetFileAttributes(absPath.c_str());
	lua_pushboolean(L, (dwAttrib != INVALID_FILE_ATTRIBUTES && !(dwAttrib & FILE_ATTRIBUTE_DIRECTORY)));
	
	return 1;
}

static int file_open(lua_State* L)
{
	const char* filename = luaL_checkstring(L, 1);
	const char* mode = luaL_optstring(L, 2, "r");

	std::string strFilename = filename;
	std::string strMode = mode;

	// Fix slashes
	std::replace(strFilename.begin(), strFilename.end(), '/', '\\');

	// Check for up directory
	if(strFilename.find("..") != std::string::npos) 
	{
		return luaL_argerror(L, 1, "Path to file was invalid");
	}

	DWORD dwDesiredAccess = 0;
	DWORD dwShareMode = 0;
	DWORD dwCreationDisposition = 0;

	if(strMode == "r")
	{
		dwDesiredAccess = GENERIC_READ;
		dwShareMode = FILE_SHARE_READ | FILE_SHARE_WRITE;
		dwCreationDisposition = OPEN_EXISTING;
	}
	else if(strMode == "w")
	{
		dwDesiredAccess = GENERIC_WRITE;
		dwShareMode = FILE_SHARE_READ;
		dwCreationDisposition = CREATE_ALWAYS;
	}
	else if(strMode == "a")
	{
		dwDesiredAccess = GENERIC_WRITE;
		dwShareMode = FILE_SHARE_READ;
		dwCreationDisposition = OPEN_ALWAYS;
	}
	else if(strMode == "r+")
	{
		dwDesiredAccess = GENERIC_READ | GENERIC_WRITE;
		dwShareMode = FILE_SHARE_READ;
		dwCreationDisposition = OPEN_EXISTING;
	}
	else if(strMode == "w+")
	{
		dwDesiredAccess = GENERIC_READ | GENERIC_WRITE;
		dwShareMode = FILE_SHARE_READ;
		dwCreationDisposition = CREATE_ALWAYS;
	}
	else if(strMode == "a+")
	{
		dwDesiredAccess = GENERIC_READ | GENERIC_WRITE;
		dwShareMode = FILE_SHARE_READ;
		dwCreationDisposition = OPEN_ALWAYS;
	}
	else
	{
		return luaL_argerror(L, 2, "Invalid mode");
	}
	
	std::wstring wideFile = Util::Widen(strFilename);
	std::wstring absPath = Settings::GetLuaFile(wideFile);

	HANDLE hFile = CreateFile(absPath.c_str(), dwDesiredAccess, dwShareMode, NULL, dwCreationDisposition, FILE_ATTRIBUTE_NORMAL, NULL);
	if(hFile == NULL)
	{
		return luaL_error(L, "Failed to get file handle (%d)", GetLastError());
	}

	if(strMode[0] == 'a')
	{
		SetFilePointer(hFile, 0, NULL, FILE_END); // Seek to end of file for append
	}

	HANDLE* ph = file_createhandleud(L);
	*ph = hFile;
	return 1;
}

static int file_close(lua_State* L)
{
	//Logging::Log("file_close called\n");
	HANDLE* phFile = ToHandleP(L);
	if(*phFile != NULL)
	{
		CloseHandle(*phFile);
		*phFile = NULL;
	}
	return 0;
}

static int file_write(lua_State* L)
{
	HANDLE hFile = ToHandleSafe(L);

	// If it's nil, just smile and wave
	if(lua_isnoneornil(L, 2))
	{
		lua_pushboolean(L, true);
		return 1;
	}

	size_t len = 0;
	const char* data = luaL_checklstring(L, 2, &len);

	DWORD bytesWritten = 0;
	lua_pushboolean(L, WriteFile(hFile, data, len, &bytesWritten, NULL));
	
	return 1;
}

static int file_gc(lua_State* L)
{
	file_close(L);
	return 0;
}

static int file_tostring(lua_State* L)
{
	HANDLE hFile = *ToHandleP(L);
	if(hFile == NULL)
	{
		lua_pushliteral(L, "file (closed)");
	}
	else
	{
		lua_pushfstring(L, "file (%p)", hFile);
	}
	return 1;
}

static const luaL_Reg flib[] = {
  {"close", file_close},
  //{"read", f_read}, TODO: Reading files, who needs that anyway
  {"write", file_write},
  {"__gc", file_gc},
  {"__tostring", file_tostring},
  {NULL, NULL}
};

static void file_createmeta(lua_State* L)
{
	luaL_newmetatable(L, LUA_WINFILEHANDLE);
	lua_pushvalue(L, -1);
	lua_setfield(L, -2, "__index");
	luaL_register(L, NULL, flib);
	lua_pop(L, 1);
}

static const luaL_Reg filelib[] = {
	{"CreateDir", file_createdir},
	{"Exists", file_exists},
	{"IsDir", file_isdir},
	{"Open", file_open},
	{NULL, NULL}
};

int luaopen_file(lua_State* L) 
{
	file_createmeta(L);

	luaL_register(L, LUA_FILELIBNAME, filelib);
	lua_pop(L, 1);

	return 0;
}

