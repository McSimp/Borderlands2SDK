// This file is based on garry's implementation as well as BlackAwps' backwards headers
#ifndef CLUAINTERFACE_H
#define CLUAINTERFACE_H

extern "C"
{
	#include "lua514/lua.h"
	#include "lua514/lualib.h"
	#include "lua514/lauxlib.h"
}

#include <stdio.h>
#include <stdarg.h>

#include "LuaInterface/CLuaObject.h"
#include "LuaInterface/ILuaTable.h"

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

		TYPE_COUNT
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

class CLuaInterface
{
public:
	CLuaInterface( );
	~CLuaInterface( );

	lua_State*		GetLuaState();

	void			PushSpecial( int type );

	CLuaObject*		Global();
	CLuaObject*		Registry();
	CLuaObject*		Environment();

	CLuaObject*		GetNewTable();
	void			NewTable();
	void			SetTable( int i );
	void			GetField( int i, const char* name );

	CLuaObject*		NewTemporaryObject();

	CLuaObject*		NewUserData( CLuaObject* metaT );
	void			PushUserData( CLuaObject* metatable, void * v, unsigned char type );
	void			PushUserData( void* data );

	void			Error( const char* strError, ... );
	//void			ErrorNoHalt( const char* strError, ... );
	void			LuaError( const char* strError, int argument = -1 );
	void			ThrowError( const char* error );

	CLuaObject*		GetGlobal( const char* name );
	void			RemoveGlobal( const char* name );
	void			NewGlobalTable( const char* name );

	CLuaObject*		GetObject( int i = -1 );
	const char*		GetString( int i = -1, unsigned int* iLen = NULL );
	int				GetInteger( int i = -1 );
	double			GetNumber( int i = -1 );
	double			GetDouble( int i = -1 );
	//float			GetFloat( int i = -1 );
	bool			GetBool( int i = -1 );
	void**			GetUserDataPtr( int i = -1 );
	void*			GetUserData( int i = -1 );
	void			GetTable( int i = -1 );
	const char*		GetStringOrError( int i );

	CUtlLuaVector*	GetAllTableMembers( int iTable );
	void			DeleteLuaVector( CUtlLuaVector* pVector );

	int				CreateReference();
	int				GetReference( int i = -1 );
	void			FreeReference( int i );
	void			PushReference( int i );

	void			Pop( int i=1 );
	int				Top();
	int				Next( int i );

	void			Push( CLuaObject* o );
	void			Push( const char* str, unsigned int iLen = 0 );
	void			PushVA( const char* str, ... );
	void			Push( double d );
	void			Push( bool b );
	void			Push( lua_CFunction f );
	void			Push( int i );
	void			Push( float f );
	void			PushLong( int i );
	void			PushNil();

	void			CheckType( int i, int iType );
	int				GetType( int iStackPos );
	const char*		GetTypeName( int iType );
	bool			IsType( int i, int iType );

	CLuaObject*		GetReturn( int iNum );

	void			Call( int args, int returns = 0 );
	int				PCall( int args, int returns = 0, int iErrorFunc = 0 );

	CLuaObject*		GetMetaTable( const char* strName, int iType );
	CLuaObject*		GetMetaTable( int i );
	void			SetMetaTable( int i );

	int				RunString( const char* string );

private:
	lua_State*			m_pState;
	CLuaObject*			m_pG;
	CLuaObject*			m_pR; 
	CLuaObject*			m_pE;
};

#endif