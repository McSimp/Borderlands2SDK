// This file is based on garry's implementation as well as BlackAwps' backwards headers
#include "LuaInterface/CLuaInterface.h"
#include "LuaInterface/UserData.h"
#include "Logging/Logging.h"

static int luabl2_print (lua_State *L) {
	int n = lua_gettop(L);  /* number of arguments */
	int i;
	lua_getglobal(L, "tostring");
	for (i=1; i<=n; i++) {
		const char *s;
		lua_pushvalue(L, -1);  /* function to be called */
		lua_pushvalue(L, i);   /* value to print */
		lua_call(L, 1, 1);
		s = lua_tostring(L, -1);  /* get result */
		if (s == NULL)
			return luaL_error(L, LUA_QL("tostring") " must return a string to "
			LUA_QL("print"));
		if (i>1) Logging::Log("\t");
		Logging::Log(s, stdout);
		lua_pop(L, 1);  /* pop result */
	}
	Logging::Log("\n", stdout);
	return 0;
}

static const luaL_Reg base_funcs[] = {
	{"print", luabl2_print},
	//{"include", luabl2_include},
	{NULL, NULL}
};

void StackDump(lua_State* L)
{
	int i=lua_gettop(L);
	Logging::Log(" ----------------  Stack Dump ----------------\n" );
	while(i) 
	{
		int t = lua_type(L, i);
		switch (t) {
		case LUA_TSTRING:
			Logging::Log("%d:`%s'\n", i, lua_tostring(L, i));
			break;
		case LUA_TBOOLEAN:
			Logging::Log("%d: %s\n",i,lua_toboolean(L, i) ? "true" : "false");
			break;
		case LUA_TNUMBER:
			Logging::Log("%d: %g\n",  i, lua_tonumber(L, i));
			break;
		default: 
			Logging::Log("%d: %s\n", i, lua_typename(L, t, i));
			break;
		}
		i--;
	}
	Logging::Log("--------------- Stack Dump Finished ---------------\n" );
}

CLuaInterface::CLuaInterface()
{
	m_pState = luaL_newstate();

	luaL_openlibs(m_pState);

	luaL_register(m_pState, "_G", base_funcs);
	lua_pop(m_pState, 1);

	this->PushSpecial(Lua::SPECIAL_GLOB);
	m_pG = new CLuaObject(this, this->CreateReference());

	this->PushSpecial(Lua::SPECIAL_REG);
	m_pR = new CLuaObject(this, this->CreateReference());

	//this->PushSpecial(Lua::SPECIAL_ENV);
	//m_pE = new CLuaObject(this, this->CreateReference());

	//m_pErrorNoHalt = GetGlobal( "ErrorNoHalt" );
}

CLuaInterface::~CLuaInterface()
{
	m_pG->UnReference();
	m_pR->UnReference();
	//m_pE->UnReference();
	//m_pErrorNoHalt->UnReference();

	lua_close(m_pState);
}

lua_State* CLuaInterface::GetLuaState()
{
	return m_pState;
}

void CLuaInterface::PushSpecial(int type)
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
		Logging::Log("[CLuaInterface] ERROR: PushSpecial - type %i is not a valid special table\n", type);
		return;
	}

	lua_pushvalue(m_pState, index);
}

CLuaObject* CLuaInterface::Global()
{
	return m_pG;
}

CLuaObject* CLuaInterface::Registry()
{
	return m_pR;
}

CLuaObject* CLuaInterface::Environment()
{
	//return m_pE;
	return NULL;
}

// DONE
CLuaObject* CLuaInterface::GetNewTable()
{
	this->NewTable();
	return new CLuaObject(this, this->CreateReference());
}

// DONE
void CLuaInterface::NewTable()
{
	lua_newtable(m_pState);
}

// DONE
void CLuaInterface::SetTable(int i)
{
	if(!lua_istable(m_pState, i))
	{
		Logging::Log("[CLuaInterface] ERROR: SetTable - not a table at stack pos %i\n", i);
		return;
	}
	lua_settable(m_pState, i);
}

// DONE
void CLuaInterface::GetField(int i, const char* name)
{
	lua_getfield(m_pState, i, name);
}

// DONE
CLuaObject* CLuaInterface::NewTemporaryObject()
{
	this->PushNil();
	return new CLuaObject(this, this->CreateReference());
}

// DONE
CLuaObject* CLuaInterface::NewUserData(CLuaObject* metaT)
{
	UserData* data = (UserData*)lua_newuserdata(m_pState, sizeof(UserData));
	CLuaObject* obj = new CLuaObject(this, this->CreateReference());

	obj->Push();
	metaT->Push();
	this->SetMetaTable(-2);
	this->Pop();

	return obj;
}

// DONE
void CLuaInterface::PushUserData(CLuaObject* metaT, void* v, unsigned char type)
{
	if(!metaT)
		this->Error("CLuaInterface - No Metatable!\n");

	UserData* data = (UserData*)lua_newuserdata(m_pState, sizeof(UserData));
	data->data = v;
	data->type = type;

	int iRef = this->CreateReference();

	this->PushReference(iRef);
	metaT->Push();
	this->SetMetaTable(-2);

	this->FreeReference(iRef);
}

// DONE
void CLuaInterface::PushUserData(void* data)
{
	lua_pushlightuserdata(m_pState, data);
}

// DONE
void CLuaInterface::Error(const char* strError, ...)
{
	char buff[ 1024 ];
	va_list argptr;
	va_start( argptr, strError );
	vsprintf_s( buff, strError, argptr );
	va_end( argptr );

	luaL_error(m_pState, "%s", buff);
}

/*
void CLuaInterface::ErrorNoHalt( const char* strError, ... )
{
	char buff[ 1024 ];
	va_list argptr;
	va_start( argptr, strError );
	vsprintf_s( buff, strError, argptr );
	va_end( argptr );

	m_pErrorNoHalt->Push();
		m_pLua->PushString( strError );
	m_pLua->Call(1,0);
}
*/

// DONE
void CLuaInterface::LuaError(const char* strError, int argument)
{
	luaL_argerror(m_pState, argument, strError);
}

// DONE
void CLuaInterface::ThrowError(const char* error)
{
	luaL_error(m_pState, "%s", error);
}

// DONE
void CLuaInterface::RemoveGlobal(const char* name)
{
	this->PushSpecial(Lua::SPECIAL_GLOB);
	this->Push(name);
	this->PushNil();
	this->SetTable(-3);
	this->Pop(); // pop the PushSpecial
}

// DONE
void CLuaInterface::NewGlobalTable(const char* name)
{
	this->PushSpecial(Lua::SPECIAL_GLOB);
	this->Push(name);
	this->NewTable();
	this->SetTable(-3);
	this->Pop(); // pop the PushSpecial
}

// DONE
CLuaObject* CLuaInterface::GetObject(int i)
{
	if(i != 0)
		this->Push(i);
	return new CLuaObject(this, this->CreateReference());
}

// DONE
const char* CLuaInterface::GetString(int i, unsigned int* iLen)
{
	unsigned int len;
	const char* result = lua_tolstring(m_pState, i, &len);

	if(iLen)
		*iLen = len;

	return result;
}

// DONE
int CLuaInterface::GetInteger(int i)
{
	return (int)this->GetNumber(i);
}

// DONE
double CLuaInterface::GetNumber(int i)
{
	return lua_tonumber(m_pState, i);
}

// DONE
double CLuaInterface::GetDouble(int i)
{
	return this->GetNumber(i);
}

// DONE
bool CLuaInterface::GetBool(int i)
{
	return lua_toboolean(m_pState, i) != 0;
}

// DONE
void** CLuaInterface::GetUserDataPtr(int i)
{
	UserData* data = (UserData*)lua_touserdata(m_pState, i);
	return &data->data; // Not sure if this is correct
}

// DONE
void* CLuaInterface::GetUserData(int i)
{
	UserData* data = (UserData*)lua_touserdata(m_pState, i);
	return data->data;
}

// DONE
void CLuaInterface::GetTable(int i)
{
	if(!lua_istable(m_pState, i))
	{
		Logging::Log("[CLuaInterface] ERROR: GetTable - not a table at stack pos %i\n", i);
		return;
	}

	lua_gettable(m_pState, i);
}

// DONE
const char* CLuaInterface::GetStringOrError(int i)
{
	this->CheckType(i, Lua::TYPE_STRING);
	return this->GetString(i);
}

// DONE
CUtlLuaVector* CLuaInterface::GetAllTableMembers(int i)
{
	if(i != 0)
		this->Push(i);

	CUtlLuaVector* tableMembers = new CUtlLuaVector();

	this->PushNil();
	while(this->Next(i - 2) != 0)
	{
		LuaKeyValue keyValues;

		keyValues.pKey = GetObject(-2);
		keyValues.pValue = GetObject(-1);

		tableMembers->push_back(keyValues);

		this->Pop();
	}

	if(i != 0)
		this->Pop(i);

	/*
	FOR_LOOP( tableMembers, j ) // Example Loop
	{
		LuaKeyValue& keyValues = tableMembers->at(j);
	}
	*/

	return tableMembers;
}

// DONE
void CLuaInterface::DeleteLuaVector(CUtlLuaVector* pVector)
{
	FOR_LOOP( pVector, i )
	{
		LuaKeyValue& keyValues = pVector->at(i);

		CLuaObject* key = keyValues.pKey;
		CLuaObject* value = keyValues.pValue;

		key->UnReference();
		value->UnReference();
	}

	if (pVector)
		delete pVector;
}

// DONE
int CLuaInterface::CreateReference()
{
	return luaL_ref(m_pState, LUA_REGISTRYINDEX);
}

// DONE
int CLuaInterface::GetReference(int i)
{
	if(i != 0)
		this->Push(i);

	return this->CreateReference();
}

// DONE
void CLuaInterface::FreeReference(int i)
{
	luaL_unref(m_pState, LUA_REGISTRYINDEX, i);
}

// DONE
void CLuaInterface::PushReference(int i)
{
	lua_rawgeti(m_pState, LUA_REGISTRYINDEX, i);
}

// DONE
void CLuaInterface::Pop(int i)
{
	int top = this->Top();
	if(top < i)
	{
		Logging::Log("[CLuaInterface] ERROR: Pop - Tried to pop higher than the top (top = %i, i = %i)\n", top, i);
		return;
	}

	lua_pop(m_pState, i);
}

// DONE
int CLuaInterface::Top()
{
	return lua_gettop(m_pState);
}

// Done
int CLuaInterface::Next(int i)
{
	return lua_next(m_pState, i);
}

// DONE
void CLuaInterface::Push(CLuaObject* o)
{
	o->Push();
}

// DONE
void CLuaInterface::Push(const char* str, unsigned int iLen)
{
	if(str == NULL)
		str = "NULL";

	if(!iLen)
		iLen = strlen(str);

	lua_pushlstring(m_pState, str, iLen);
}

// DONE
void CLuaInterface::PushVA(const char* str, ...)
{
	char buff[1024];
	va_list argptr;
	va_start(argptr, str);
	int len = vsprintf_s(buff, str, argptr);
	va_end(argptr);

	this->Push(buff, len);
}

// DONE
void CLuaInterface::Push(double d)
{
	lua_pushnumber(m_pState, d);
}

// DONE
void CLuaInterface::Push(bool b)
{
	lua_pushboolean(m_pState, (int)b);
}

// DONE
void CLuaInterface::Push(lua_CFunction f)
{
	lua_pushcfunction(m_pState, f);
}

// DONE
void CLuaInterface::Push(int i)
{
	lua_pushnumber(m_pState, i);
}

// DONE
void CLuaInterface::Push(float f)
{
	lua_pushnumber(m_pState, f);
}

// DONE
void CLuaInterface::PushLong(int i)
{
	lua_pushnumber(m_pState, i);
}

// DONE
void CLuaInterface::PushNil()
{
	lua_pushnil(m_pState);
}

// DONE, check this does what we want
void CLuaInterface::CheckType(int i, int iType)
{
	luaL_checktype(m_pState, i, iType);
}

// DONE, but TODO change lua_type for new metatable
int CLuaInterface::GetType(int iStackPos)
{
	return lua_type(m_pState, iStackPos);
}

// DONE
const char* CLuaInterface::GetTypeName(int iType)
{
	if(iType < 0 || iType >= Lua::TYPE_COUNT)
	{
		Logging::Log("[CLuaInterface] WARNING: GetTypeName - type %i is out of range\n", iType);
		return "invalid";
	}

	return Lua::TypeName[iType];
}

// DONE
bool CLuaInterface::IsType(int i, int iType)
{
	return lua_type(m_pState, i) == iType;
}

CLuaObject* CLuaInterface::GetReturn( int iNum )
{
	return GetObject( iNum );
}

// DONE
void CLuaInterface::Call(int args, int returns)
{
	int funcStackPos = -(args)-1;
	if(!lua_isfunction(m_pState, funcStackPos))
	{
		Logging::Log("[CLuaInterface] ERROR: Call - stack pos %i is not a function\n", funcStackPos);
		return;
	}

	lua_call(m_pState, args, returns);
}

// DONE
int CLuaInterface::PCall(int args, int returns, int iErrorFunc)
{
	int funcStackPos = -(args)-1;
	if(!lua_isfunction(m_pState, funcStackPos))
	{
		Logging::Log("[CLuaInterface] ERROR: PCall - stack pos %i is not a function\n", funcStackPos);
		return -1;
	}

	if(iErrorFunc && !lua_isfunction(m_pState, iErrorFunc))
	{
		Logging::Log("[CLuaInterface] ERROR: PCall - stack pos %i (for error func) is not a function\n", funcStackPos);
		return -1;
	}

	return lua_pcall(m_pState, args, returns, iErrorFunc);
}

CLuaObject* CLuaInterface::GetMetaTable(const char* strName, int iType)
{
	luaL_newmetatable_type(m_pState, strName, iType);
	return new CLuaObject(this, this->CreateReference());
}

CLuaObject* CLuaInterface::GetMetaTable(int i)
{
	if(lua_getmetatable(m_pState, i) != 0)
	{
		return new CLuaObject(this, this->CreateReference());
	}
	else
	{
		return NULL;
	}
}

void CLuaInterface::SetMetaTable(int i)
{
	if(!lua_istable(m_pState, -1))
	{
		Logging::Log("[CLuaInterface] ERROR: SetMetaTable - top of the stack isn't a table\n");
		return;
	}

	if(lua_isnil(m_pState, i))
	{
		Logging::Log("[CLuaInterface] ERROR: SetMetaTable - stack pos %i is nil\n", i);
		return;
	}

	lua_setmetatable(m_pState, i);
}

int CLuaInterface::RunString(const char* string)
{
	int error = luaL_dostring(m_pState, string);
	if(error != 0)
	{
		Logging::Log("[CLuaInterface] ERROR: RunString failed - %s\n", lua_tostring(m_pState, -1));
		lua_pop(m_pState, 1);
	}
	return error;
}