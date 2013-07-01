#ifndef CLUAINTERFACE_H
#define CLUAINTERFACE_H

#include "lua.hpp"
#include <string>

struct FileHash
{
	const wchar_t* file;
	const char* hash;
};

class CLuaInterface
{
public:
	CLuaInterface();
	~CLuaInterface();

	bool			InitializeModules();
	lua_State*		GetLuaState();
	int				RunString(const char* string);
	int				DoFile(const std::string& filename);
	int				DoFileAbsolute(const std::string& path);

private:
	void			InitializeState();
	void			CleanupState();
	void			SetSDKValues();
	void			SetPaths();
	bool			VerifyLuaFiles();
	bool			CheckHash(FileHash* fileHash);

	lua_State*		m_pState;
	std::string		m_luaPath;
};

#endif