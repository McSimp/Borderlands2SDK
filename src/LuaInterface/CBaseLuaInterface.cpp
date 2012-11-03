#include "LuaInterface/CBaseLuaInterface.h"
#include "Logging/Logging.h"

int CBaseLuaInterface::Top()
{
	return lua_gettop(m_pState);
}

void CBaseLuaInterface::Push(int stackPos)
{
	// TODO: Make sure stackpos is reasonable
	lua_pushvalue(m_pState, stackPos);
}

void CBaseLuaInterface::Pop(int amount)
{
	int top = this->Top();
	if(top < amount)
	{
		Logging::Log("[CBaseLuaInterface] ERROR: Pop - Tried to pop higher than the top (top = %i, amt = %i)\n", top, amount);
		return;
	}

	lua_pop(m_pState, amount);
}

void CBaseLuaInterface::GetTable(int stackPos)
{
	if(!lua_istable(m_pState, stackPos))
	{
		Logging::Log("[CBaseLuaInterface] ERROR: GetTable - not a table at stack pos %i\n", stackPos);
		return;
	}

	lua_gettable(m_pState, stackPos);
}

void CBaseLuaInterface::GetField(int stackPos, const char* name)
{
	lua_getfield(m_pState, stackPos, name);
}

void CBaseLuaInterface::SetField(int stackPos, const char* name)
{
	lua_setfield(m_pState, stackPos, name);
}

void CBaseLuaInterface::CreateTable()
{
	lua_newtable(m_pState);
}

// !!
void CBaseLuaInterface::SetTable(int stackPos)
{
	if(!lua_istable(m_pState, stackPos))
	{
		Logging::Log("[CBaseLuaInterface] ERROR: SetTable - not a table at stack pos %i\n", stackPos);
		return;
	}
	lua_settable(m_pState, stackPos);
}

void CBaseLuaInterface::SetMetaTable(int stackPos)
{
	if(!lua_istable(m_pState, -1))
	{
		Logging::Log("[CBaseLuaInterface] ERROR: SetMetaTable - top of the stack isn't a table\n");
		return;
	}

	if(lua_isnil(m_pState, stackPos))
	{
		Logging::Log("[CBaseLuaInterface] ERROR: SetMetaTable - stack pos %i is nil\n", stackPos);
		return;
	}

	lua_setmetatable(m_pState, stackPos);
}
	
bool CBaseLuaInterface::GetMetaTable(int stackPos)
{
	return lua_getmetatable(m_pState, stackPos) != 0;
}

void CBaseLuaInterface::Call(int args, int results)
{
	int funcStackPos = -(args)-1;
	if(!lua_isfunction(m_pState, funcStackPos))
	{
		Logging::Log("[CBaseLuaInterface] ERROR: Call - stack pos %i is not a function\n", funcStackPos);
		return;
	}

	lua_call(m_pState, args, results);
}

// !!
int CBaseLuaInterface::PCall(int args, int results, int errorFunc)
{
	int funcStackPos = -(args)-1;
	if(!lua_isfunction(m_pState, funcStackPos))
	{
		Logging::Log("[CBaseLuaInterface] ERROR: PCall - stack pos %i is not a function\n", funcStackPos);
		return -1;
	}

	if(errorFunc && !lua_isfunction(m_pState, errorFunc))
	{
		Logging::Log("[CBaseLuaInterface] ERROR: PCall - stack pos %i (for error func) is not a function\n", funcStackPos);
		return -1;
	}

	return lua_pcall(m_pState, args, results, errorFunc);
}

int CBaseLuaInterface::Equal(int a, int b)
{
	return lua_equal(m_pState, a, b);
}

int CBaseLuaInterface::RawEqual(int a, int b)
{
	return lua_rawequal(m_pState, a, b);
}

void CBaseLuaInterface::Insert(int stackPos)
{
	lua_insert(m_pState, stackPos);
}

void CBaseLuaInterface::Remove(int stackPos)
{
	lua_remove(m_pState, stackPos);
}

int CBaseLuaInterface::Next(int stackPos)
{
	return lua_next(m_pState, stackPos);
}

void* CBaseLuaInterface::NewUserdata(unsigned int size)
{
	return lua_newuserdata(m_pState, size);
}

void CBaseLuaInterface::ThrowError(const char* error)
{
	luaL_error(m_pState, "%s", error);
}

void CBaseLuaInterface::CheckType(int stackPos, int type)
{
	luaL_checktype(m_pState, stackPos, type);
}

void CBaseLuaInterface::ArgError(int argNum, const char* message)
{
	luaL_argerror(m_pState, argNum, message);
}

void CBaseLuaInterface::RawGet(int stackPos)
{
	lua_rawget(m_pState, stackPos);
}

void CBaseLuaInterface::RawSet(int stackPos)
{
	lua_rawset(m_pState, stackPos);
}

const char*	CBaseLuaInterface::GetString(int stackPos, unsigned int* outLen)
{
	unsigned int len;
	const char* result = lua_tolstring(m_pState, stackPos, &len);

	if(outLen)
		*outLen = len;

	return result;
}

double CBaseLuaInterface::GetNumber(int stackPos)
{
	return lua_tonumber(m_pState, stackPos);
}

bool CBaseLuaInterface::GetBool(int stackPos)
{
	return lua_toboolean(m_pState, stackPos) != 0;
}

lua_CFunction CBaseLuaInterface::GetCFunction(int stackPos)
{
	return lua_tocfunction(m_pState, stackPos);
}

void* CBaseLuaInterface::GetUserdata(int stackPos)
{
	return lua_touserdata(m_pState, stackPos);
}

void CBaseLuaInterface::PushNil()
{
	lua_pushnil(m_pState);
}

void CBaseLuaInterface::PushString(const char* val, unsigned int len)
{
	if(val == NULL)
		val = "NULL";

	if(!len)
		len = strlen(val);

	lua_pushlstring(m_pState, val, len);
}

void CBaseLuaInterface::PushNumber(double val)
{
	lua_pushnumber(m_pState, val);
}

void CBaseLuaInterface::PushBool(bool val)
{
	lua_pushboolean(m_pState, (int)val);
}

void CBaseLuaInterface::PushCFunction(lua_CFunction val)
{
	lua_pushcfunction(m_pState, val);
}

void CBaseLuaInterface::PushCClosure(lua_CFunction val, int vars)
{
	lua_pushcclosure(m_pState, val, vars);
}

void CBaseLuaInterface::PushUserdata(void* data)
{
	lua_pushlightuserdata(m_pState, data);
}

int CBaseLuaInterface::ReferenceCreate()
{
	return luaL_ref(m_pState, -1234);
}

void CBaseLuaInterface::ReferenceFree(int ref)
{
	luaL_unref(m_pState, -1234, ref);
}

void CBaseLuaInterface::ReferencePush(int ref)
{
	lua_rawgeti(m_pState, -1234, ref);
}

// !!
void CBaseLuaInterface::PushSpecial(int type)
{
	int index;
	if(type == Lua::SPECIAL_GLOB)
	{
		index = LUA_GLOBALSINDEX;
	}
	else if(type == Lua::SPECIAL_ENV)
	{
		index = LUA_ENVIRONINDEX;
	}
	else if(type == Lua::SPECIAL_REG)
	{
		index = LUA_REGISTRYINDEX;
	}
	else
	{
		Logging::Log("[CBaseLuaInterface] ERROR: PushSpecial - type %i is not a valid special table\n", type);
		return;
	}

	lua_pushvalue(m_pState, index);
}

// !!
bool CBaseLuaInterface::IsType(int stackPos, int type)
{
	return lua_type(m_pState, stackPos) == type;
}

// !! Userdata
int CBaseLuaInterface::GetType(int stackPos)
{
	return lua_type(m_pState, stackPos);
}

const char* CBaseLuaInterface::GetTypeName(int type)
{
	if(type < 0 || type > 8)
	{
		Logging::Log("[CBaseLuaInterface] WARNING: GetTypeName - type %i is out of range\n", type);
		return "invalid";
	}

	return Lua::TypeName[type]; 
}

// This is GMod specific, see luaL_newmetatable in lua_shared.dylib to see what garry has done
void CBaseLuaInterface::CreateMetaTableType(const char* name, int type)
{}

const char* CBaseLuaInterface::CheckString(int stackPos)
{
	return luaL_checkstring(m_pState, stackPos);
}

double CBaseLuaInterface::CheckNumber(int stackPos)
{
	return luaL_checknumber(m_pState, stackPos);
}