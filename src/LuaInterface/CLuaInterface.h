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
	void			CallShutdownFuncs();

private:
	void			InitializeState();
	void			CleanupState();
	void			SetSDKValues();
	void			SetPaths();
	bool			VerifyLuaFiles();
	bool			CheckHash(FileHash* fileHash);
	int				DoFile(const std::string& filename);
	int				DoFileAbsolute(const std::string& path);

	lua_State*		m_pState;
	std::string		m_luaPath;
	bool			m_modulesInitialized;
};

#endif