// This is based off garry's CBaseLuaInterface and IBaseLua. Well, it's pretty much the exact same thing. 
// All credit goes to him for making this. Hope it's cool with you garry.

#ifndef CBASELUAINTERFACE_H
#define CBASELUAINTERFACE_H

extern "C"
{
	#include "lua514/lua.h"
	#include "lua514/lualib.h"
	#include "lua514/lauxlib.h"
}
#include <string>

class CBaseLuaInterface
{
public:
	int			Top();
	void		Push(int stackPos);
	void		Pop(int amount = 1);
	void		GetTable(int stackPos);
	void		GetField(int stackPos, const char* name);
	void		SetField(int stackPos, const char* name);
	void		CreateTable();
	void		SetTable(int stackPos);
	void		SetMetaTable(int stackPos);
	bool		GetMetaTable(int stackPos);
	void		Call(int args, int results);
	int			PCall(int args, int results, int errorFunc);
	int			Equal(int a, int b);
	int			RawEqual(int a, int b);
	void		Insert(int stackPos);
	void		Remove(int stackPos);
	int			Next(int stackPos);
	void*		NewUserdata(unsigned int size);
	void		ThrowError(const char* error);
	void		CheckType(int stackPos, int type);
	void		ArgError(int argNum, const char* message);
	void		RawGet(int stackPos);
	void		RawSet(int stackPos);

	const char*		GetString(int stackPos = -1, unsigned int* outLen = NULL);
	double			GetNumber(int stackPos = -1);
	bool			GetBool(int stackPos = -1);
	lua_CFunction	GetCFunction(int stackPos = -1);
	void*			GetUserdata(int stackPos = -1);

	void		PushNil();
	void		PushString(const char* val, unsigned int len);
	void		PushNumber(double val);
	void		PushBool(bool val);
	void		PushCFunction(lua_CFunction val);
	void		PushCClosure(lua_CFunction val, int vars);
	void		PushUserdata(void* data);

	//
	// If you create a reference - don't forget to free it!
	//
	int			ReferenceCreate();
	void		ReferenceFree(int ref);
	void		ReferencePush(int ref);

	//
	// Push a special value onto the top of the stack ( see below )
	//
	void		PushSpecial(int type);

	//
	// For type enums see below 
	//
	bool			IsType(int stackPos, int type);
	int				GetType(int stackPos);
	const char*		GetTypeName(int type);

	//
	// Creates a new meta table of string and type and leaves it on the stack.
	// Will return the old meta table of this name if it already exists.
	//
	void			CreateMetaTableType(const char* name, int type);

	//
	// Like Get* but throws errors and returns if they're not of the expected type
	//
	const char*		CheckString(int stackPos = -1);
	double			CheckNumber(int stackPos = -1);

private:
	lua_State* m_pState;
};

namespace Lua
{
	enum 
	{
		SPECIAL_GLOB,		// Global table
		SPECIAL_ENV,		// Environment table
		SPECIAL_REG,		// Registry table
	};

	enum
	{
		TYPE_INVALID = -1,
		TYPE_NIL, 
		TYPE_BOOL,
		TYPE_LIGHTUSERDATA,
		TYPE_NUMBER, 
		TYPE_STRING, 
		TYPE_TABLE,
		TYPE_FUNCTION,
		TYPE_USERDATA,
		TYPE_THREAD,
	};

	static const char* TypeName[] = 
	{
		"nil",
		"bool",
		"lightuserdata",
		"number",
		"string",
		"table",
		"function",
		"userdata",
		"thread",
		0
	};
}
#endif