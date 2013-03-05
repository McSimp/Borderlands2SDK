// This file is based on garry's implementation as well as BlackAwps' backwards headers
#include "LuaInterface/CLuaInterface.h"
#include "LuaInterface/UserData.h"
#include "BL2SDK/Logging.h"
#include "BL2SDK/Settings.h"
#include "BL2SDK/Util.h"
#include "LuaInterface/LuaManager.h"
#include <algorithm>
#undef GetObject // FUCKING WINDOWS 98

static int luabl2_print (lua_State *L) {
	int n = lua_gettop(L);  /* number of arguments */
	int i;
	lua_getglobal(L, "tostring");
	for (i=1; i<=n; i++) {
		const char *s;
		lua_pushvalue(L, -1);  /* function to be called */
		lua_pushvalue(L, i);   /* value to print */
		lua_call(L, 1, 1);
		size_t len;
		s = lua_tolstring(L, -1, &len); /* get result */
		if (s == NULL)
			return luaL_error(L, LUA_QL("tostring") " must return a string to "
			LUA_QL("print"));
		if (i>1) Logging::Log("\t");
		Logging::Log(s, len);
		lua_pop(L, 1);  /* pop result */
	}
	Logging::Log("\n");
	return 0;
}

static int luabl2_include (lua_State *L) {
	lua_Debug dbg1;
	lua_getstack(L, 1, &dbg1);
	lua_getinfo(L, "f", &dbg1);
	lua_Debug dbg2;
	lua_getinfo(L, ">S", &dbg2);

	std::string source = dbg2.source; // eg: @D:\dev\bl\Borderlands2SDK\bin\Debug\lua\test.lua
	std::string filename = luaL_checkstring(L, 1);
	std::replace(filename.begin(), filename.end(), '/', '\\');
	std::string path = source.substr(1, source.find_last_of("\\/")) + filename; // Cuts off the @ at the start of the path and removes the filename
	
	LuaManager::g_Lua->DoFileAbsolute(path.c_str());

	return 0;
}

static const luaL_Reg base_funcs[] = {
	{"print", luabl2_print},
	{"include", luabl2_include},
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
			Logging::LogF("%d:`%s'\n", i, lua_tostring(L, i));
			break;
		case LUA_TBOOLEAN:
			Logging::LogF("%d: %s\n",i,lua_toboolean(L, i) ? "true" : "false");
			break;
		case LUA_TNUMBER:
			Logging::LogF("%d: %g\n",  i, lua_tonumber(L, i));
			break;
		default: 
			Logging::LogF("%d: %s\n", i, lua_typename(L, t));
			break;
		}
		i--;
	}
	Logging::Log("--------------- Stack Dump Finished ---------------\n" );
}

// VIRT
CLuaInterface::CLuaInterface()
{
	m_pState = luaL_newstate();

	luaL_openlibs(m_pState);

	luaL_register(m_pState, "_G", base_funcs);
	lua_pop(m_pState, 1);

	this->SetPaths();

	this->PushSpecial(Lua::SPECIAL_GLOB);
	m_pG = new CLuaObject(this, this->CreateReference());

	this->PushSpecial(Lua::SPECIAL_REG);
	m_pR = new CLuaObject(this, this->CreateReference());

	//this->PushSpecial(Lua::SPECIAL_ENV);
	//m_pE = new CLuaObject(this, this->CreateReference());

	//m_pErrorNoHalt = GetGlobal( "ErrorNoHalt" );
}

// VIRT
CLuaInterface::~CLuaInterface()
{
	m_pG->UnReference();
	m_pR->UnReference();
	//m_pE->UnReference();
	//m_pErrorNoHalt->UnReference();

	lua_close(m_pState);
}

// VIRT
lua_State* CLuaInterface::GetLuaState()
{
	return m_pState;
}

// BASE DONE
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
		Logging::LogF("[CLuaInterface] ERROR: PushSpecial - type %i is not a valid special table\n", type);
		index = LUA_REFNIL; // Check
	}

	lua_pushvalue(m_pState, index);
}

// VIRT
CLuaObject* CLuaInterface::Global()
{
	return m_pG;
}

// VIRT
CLuaObject* CLuaInterface::Registry()
{
	return m_pR;
}

// VIRT
CLuaObject* CLuaInterface::Environment()
{
	//return m_pE;
	return NULL;
}

// VIRT
CLuaObject* CLuaInterface::GetNewTable()
{
	this->NewTable();
	return new CLuaObject(this, this->CreateReference());
}

// VIRT (Direct to base) DONE
void CLuaInterface::NewTable()
{
	lua_newtable(m_pState);
}

// BASE DONE (TODO: Give type that SetTable is trying to set)
void CLuaInterface::SetTable(int i)
{
	if(!lua_istable(m_pState, i))
	{
		Logging::LogF("[CLuaInterface] ERROR: SetTable - not a table at stack pos %i\n", i);
		return;
	}
	lua_settable(m_pState, i);
}

// BASE DONE
void CLuaInterface::GetField(int i, const char* name)
{
	lua_getfield(m_pState, i, name);
}

// VIRT
CLuaObject* CLuaInterface::NewTemporaryObject()
{
	this->PushNil();
	return new CLuaObject(this, this->CreateReference());
}

// VIRT
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

// VIRT
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

// BASE DONE
void CLuaInterface::PushUserData(void* data)
{
	lua_pushlightuserdata(m_pState, data);
}

// VIRT
void CLuaInterface::Error(const char* strError, ...)
{
	char buff[1024];
	va_list argptr;
	va_start(argptr, strError);
	vsprintf_s(buff, strError, argptr);
	va_end(argptr);

	this->ThrowError(buff);
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

// VIRT (Direct to base) DONE
void CLuaInterface::LuaError(const char* strError, int argument)
{
	luaL_argerror(m_pState, argument, strError);
}

// BASE DONE
void CLuaInterface::ThrowError(const char* error)
{
	luaL_error(m_pState, "%s", error);
}

// VIRT
void CLuaInterface::TypeError(const char* expectedTypeName, int iStackPos)
{
	luaL_typerror(m_pState, iStackPos, expectedTypeName);
}

// VIRT
CLuaObject* CLuaInterface::GetGlobal(const char* name)
{
	this->PushSpecial(Lua::SPECIAL_GLOB);
		this->GetField(-1, name);
		CLuaObject* o = new CLuaObject(this, this->CreateReference());
	this->Pop();
	return o;
}

// VIRT
void CLuaInterface::RemoveGlobal(const char* name)
{
	this->PushSpecial(Lua::SPECIAL_GLOB);
		this->Push(name);
		this->PushNil();
		this->SetTable(-3);
	this->Pop();
}

// VIRT
void CLuaInterface::NewGlobalTable(const char* name)
{
	this->PushSpecial(Lua::SPECIAL_GLOB);
		this->Push(name);
		this->NewTable();
		this->SetTable(-3);
	this->Pop();
}

// VIRT
CLuaObject* CLuaInterface::GetObject(int i)
{
	if(i != 0)
		this->Push(i);
	return new CLuaObject(this, this->CreateReference());
}

// VIRT (Direct to base) DONE
const char* CLuaInterface::GetString(int i, unsigned int* iLen)
{
	unsigned int len;
	const char* result = lua_tolstring(m_pState, i, &len);

	if(iLen)
		*iLen = len;

	return result;
}

// VIRT
int CLuaInterface::GetInteger(int i)
{
	return (int)this->GetNumber(i);
}

// VIRT (Direct to base) DONE
double CLuaInterface::GetNumber(int i)
{
	return lua_tonumber(m_pState, i);
}

// VIRT
double CLuaInterface::GetDouble(int i)
{
	return this->GetNumber(i);
}

// VIRT (Direct to base) DONE
bool CLuaInterface::GetBool(int i)
{
	return lua_toboolean(m_pState, i) != 0;
}

// BASE of GetUserdata DONE
void* CLuaInterface::GetBaseUserData(int i)
{
	return lua_touserdata(m_pState, i);
}

// VIRT
void** CLuaInterface::GetUserDataPtr(int i)
{
	UserData* data = (UserData*)lua_touserdata(m_pState, i);
	return &data->data; // Not sure if this is correct
}

// VIRT
void* CLuaInterface::GetUserData(int i)
{
	UserData* data = (UserData*)lua_touserdata(m_pState, i);
	return data->data;
}

// BASE (Unknown VIRT) DONE
void CLuaInterface::GetTable(int i)
{
	if(!lua_istable(m_pState, i))
	{
		Logging::LogF("[CLuaInterface] ERROR: GetTable - not a table at stack pos %i\n", i);
		return;
	}

	lua_gettable(m_pState, i);
}

// VIRT
const char* CLuaInterface::GetStringOrError(int i)
{
	this->CheckType(i, Lua::TYPE_STRING);
	return this->GetString(i);
}

// VIRT DONE
CUtlLuaVector* CLuaInterface::GetAllTableMembers(int i)
{
	if(i != 0)
		this->Push(i);

	if(this->IsType(-1, Lua::TYPE_TABLE))
    {
		this->ThrowError("ILuaInterface::GetAllTableMembers, object not a table !");
        return NULL;
    }

	CUtlLuaVector* tableMembers = new CUtlLuaVector();

	this->PushNil();
	while(this->Next(-2) != 0) // ???
	{
		LuaKeyValue keyValues;

		keyValues.pKey = this->GetObject(-2);
		keyValues.pValue = this->GetObject(-1);

		tableMembers->push_back(keyValues);

		keyValues.pKey->Push(); // Push key back for next loop
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

// VIRT
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

int CLuaInterface::CreateReference()
{
	return luaL_ref(m_pState, LUA_REGISTRYINDEX);
}

// VIRT
int CLuaInterface::GetReference(int i)
{
	if(i != 0)
		this->Push(i);

	return this->CreateReference();
}

void CLuaInterface::FreeReference(int i)
{
	lua_unref(m_pState, i);
}

void CLuaInterface::PushReference(int i)
{
	lua_getref(m_pState, i);
}

// BASE AND VIRT (Calls base) DONE
void CLuaInterface::Pop(int i)
{
	int top = this->Top();
	if(top < i)
	{
		Logging::LogF("[CLuaInterface] ERROR: Pop - Tried to pop higher than the top (top = %i, i = %i)\n", top, i);
		return;
	}

	lua_pop(m_pState, i);
}

// BASE AND VIRT (Calls base) DONE
int CLuaInterface::Top()
{
	return lua_gettop(m_pState);
}

// BASE DONE
int CLuaInterface::Next(int i)
{
	return lua_next(m_pState, i);
}

// THIS IS THE BASE FUNCTION PUSH
void CLuaInterface::PushCopy(int i)
{
	return lua_pushvalue(m_pState, i);
}

// VIRT
void CLuaInterface::Push(CLuaObject* o)
{
	o->Push();
}

// VIRT (Direct to base) DONE
void CLuaInterface::Push(const char* str, unsigned int iLen)
{
	if(str == NULL)
		str = "NULL"; // This is a problem waiting to happen.

	if(!iLen)
		iLen = strlen(str);

	lua_pushlstring(m_pState, str, iLen);
}

// VIRT DONE
void CLuaInterface::PushVA(const char* str, ...)
{
	char buff[1024];
	va_list argptr;
	va_start(argptr, str);
	int len = vsprintf_s(buff, str, argptr);
	va_end(argptr);

	this->Push(buff, len);
}

// VIRT DONE
void CLuaInterface::Push(double d)
{
	lua_pushnumber(m_pState, d);
}

// VIRT DONE
void CLuaInterface::Push(bool b)
{
	lua_pushboolean(m_pState, (int)b);
}

// VIRT DONE
void CLuaInterface::Push(lua_CFunction f)
{
	lua_pushcfunction(m_pState, f);
}

// VIRT (Direct to base) DONE
void CLuaInterface::Push(int i)
{
	lua_pushnumber(m_pState, i);
}

// VIRT DONE
void CLuaInterface::Push(float f)
{
	lua_pushnumber(m_pState, f);
}

// VIRT DONE
void CLuaInterface::PushLong(int i)
{
	lua_pushnumber(m_pState, i);
}

void CLuaInterface::PushNil()
{
	lua_pushnil(m_pState);
}

// BASE AND VIRT DONE
void CLuaInterface::CheckType(int i, int iType)
{
	int luaType = this->GetType(i);
	if(luaType != iType)
	{
		const char* typeName = this->GetTypeNameEx(i);
		this->TypeError(typeName, i);
	}
}

// BASE AND VIRT (DO SAME THING) DONE, but TODO check this works
int CLuaInterface::GetType(int iStackPos)
{
	int type = lua_type(m_pState, iStackPos);
	if(type == Lua::TYPE_USERDATA)
	{
		UserData* data = (UserData*)lua_touserdata(m_pState, iStackPos);
		int udType = data->type;
		if(udType >= Lua::TYPE_COUNT)
		{
			return udType;
		}
	}
	
	return type;
}

// BASE AND VIRT DONE, but this won't really work
const char* CLuaInterface::GetTypeName(int iType)
{
	if(iType < 0 || iType >= Lua::TYPE_COUNT)
	{
		Logging::LogF("[CLuaInterface] WARNING: GetTypeName - type %i is out of range\n", iType);
		return "invalid";
	}

	return Lua::TypeName[iType];
}

const char* CLuaInterface::GetTypeNameEx(int iStackPos)
{
	int luaType = lua_type(m_pState, iStackPos);
	if(luaType == Lua::TYPE_USERDATA)
	{
		if(lua_getmetatable(m_pState, iStackPos))
		{
			lua_pushstring(m_pState, "__type");
			lua_rawget(m_pState, -2);
			if(lua_isstring(m_pState, -1))
			{
				const char* name = lua_tostring(m_pState, -1); // This could be asking for trouble
				lua_pop(m_pState, 1);
				return name;
			}
			else
			{
				Logging::Log("[CLuaInterface] Userdata without metatable?\n");
				lua_pop(m_pState, 1);
			}
		}

		return "UnknownUserData";
	}
	else
	{
		return this->GetTypeName(luaType);
	}
}

// BASE DONE BUT NEEDS TO BE CHECKED!
bool CLuaInterface::IsType(int i, int iType)
{
	int type = this->GetType(i);
	return type == iType;
}

// VIRT
CLuaObject* CLuaInterface::GetReturn( int iNum )
{
	return this->GetObject( iNum );
}

// BASE AND VIRT DONE
void CLuaInterface::Call(int args, int returns)
{
	int funcStackPos = -(args)-1;
	if(!lua_isfunction(m_pState, funcStackPos))
	{
		Logging::LogF("[CLuaInterface] ERROR: Call - stack pos %i is not a function\n", funcStackPos);
		return;
	}

	lua_call(m_pState, args, returns);
}

// BASE AND VIRT DONE
int CLuaInterface::PCall(int args, int returns, int iErrorFunc)
{
	int funcStackPos = -(args)-1;
	if(!lua_isfunction(m_pState, funcStackPos))
	{
		Logging::LogF("[CLuaInterface] ERROR: PCall - stack pos %i is not a function\n", funcStackPos);
		return -1;
	}

	if(iErrorFunc && !lua_isfunction(m_pState, iErrorFunc))
	{
		Logging::LogF("[CLuaInterface] ERROR: PCall - stack pos %i (for error func) is not a function\n", iErrorFunc);
		return -1;
	}

	return lua_pcall(m_pState, args, returns, iErrorFunc);
}

// VIRT DONE
CLuaObject* CLuaInterface::GetMetaTable(const char* strName)
{
	if(luaL_newmetatable(m_pState, strName) == 1) // Means that a new metatable had to be created
	{
		lua_pushstring(m_pState, strName);
		lua_setfield(m_pState, -2, "__type");
	}
	return new CLuaObject(this, this->CreateReference());
}

// VIRT (Calls base correctly) DONE
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

// BASE DONE
void CLuaInterface::SetMetaTable(int i)
{
	if(!lua_istable(m_pState, -1))
	{
		Logging::Log("[CLuaInterface] ERROR: SetMetaTable - top of the stack isn't a table\n");
		return;
	}

	if(lua_isnil(m_pState, i))
	{
		Logging::LogF("[CLuaInterface] ERROR: SetMetaTable - stack pos %i is nil\n", i);
		return;
	}

	lua_setmetatable(m_pState, i);
}

int CLuaInterface::RunString(const char* string)
{
	int error = luaL_dostring(m_pState, string);
	if(error != 0)
	{
		Logging::LogF("[CLuaInterface] ERROR: RunString failed - %s\n", lua_tostring(m_pState, -1));
		lua_pop(m_pState, 1);
	}
	return error;
}

int CLuaInterface::DoFile(const char* filename)
{
	return this->DoFileAbsolute(Util::Format("%s\\%s", m_luaPath.c_str(), filename).c_str());
}

int CLuaInterface::DoFileAbsolute(const char* path)
{
	int status = luaL_dofile(m_pState, path);
	if(status != 0)
	{
		Logging::LogF("[CLuaInterface] ERROR: DoFile failed to run file - %s\n", lua_tostring(m_pState, -1));
		this->Pop();
	}
	return status;
}

void CLuaInterface::SetPaths()
{
	// Set path to Lua folder, without trailing slash
	m_luaPath = Util::Narrow(Settings::GetBinFile(L"lua"));
	Logging::LogF("[CLuaInterface] Lua Path = %s\n", m_luaPath.c_str());

	CLuaObject* pkg = this->GetGlobal(LUA_LOADLIBNAME);
	CLuaObject* pathobj = pkg->GetMember("path");
	const char* pkgpath = pathobj->GetString();

	std::string newpath = Util::Format("%s\\includes\\modules\\?.lua;%s", m_luaPath.c_str(), pkgpath);
	pkg->SetMember("path", newpath.c_str());

	pathobj->UnReference();
	pkg->UnReference();
}