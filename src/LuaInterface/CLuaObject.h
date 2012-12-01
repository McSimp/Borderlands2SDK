// This file is based on garry's implementation as well as BlackAwps' backwards headers
#ifndef CLUAOBJECT_H
#define CLUAOBJECT_H

#include "LuaInterface/CLuaInterface.h"
#include "LuaInterface/ILuaTable.h"

class CLuaInterface;

class CLuaObject
{
public:
	CLuaObject( CLuaInterface* lua );
	CLuaObject( CLuaInterface* lua, int iRef );
	CLuaObject( CLuaInterface* lua, CLuaObject* obj );
	~CLuaObject( void );

	void			Set( CLuaObject* obj );
	void			SetNil();
	void			SetFromStack( int i );
	
	void			UnReference();
	int				GetReference();

	int				GetType();
	const char*		GetTypeName();

	const char*		GetString( unsigned int* iLen = NULL );
	int				GetInt();
	double			GetDouble();
	float			GetFloat();
	bool			GetBool();
	void*			GetUserData();

	CUtlLuaVector*	GetMembers();
	
	void			SetMember( const char* name );
	void			SetMember( const char* name, CLuaObject* obj );
	void			SetMember( const char* name, double d );
	void			SetMember( const char* name, bool b );
	void			SetMember( const char* name, const char* s, unsigned int iLen = 0 );
	void			SetMember( const char* name, lua_CFunction f );
	
	void			SetMember( double dKey );
	void			SetMember( double dKey, CLuaObject* obj );
	void			SetMember( double dKey, double d );
	void			SetMember( double dKey, bool b );
	void			SetMember( double dKey, const char* s, unsigned int iLen = 0 );
	void			SetMember( double dKey, lua_CFunction f );

	void			SetMember( float fKey );
	void			SetMember( float fKey, CLuaObject* obj );
	void			SetMember( float fKey, double d );
	void			SetMember( float fKey, bool b );
	void			SetMember( float fKey, const char* s, unsigned int iLen = 0 );
	void			SetMember( float fKey, lua_CFunction f );

	void			SetMember( int iKey );
	void			SetMember( int iKey, CLuaObject* obj );
	void			SetMember( int iKey, double d );
	void			SetMember( int iKey, bool b );
	void			SetMember( int iKey, const char* s, unsigned int iLen = 0 );
	void			SetMember( int iKey, lua_CFunction f );

	CLuaObject*		GetMember( const char* name );
	CLuaObject*		GetMember( double dKey );
	CLuaObject*		GetMember( float fKey );
	CLuaObject*		GetMember( int iKey );
	CLuaObject*		GetMember( CLuaObject* oKey );

	bool			GetMemberBool( const char* name, bool b = true );
	int				GetMemberInt( const char* name, int i = 0 );
	float			GetMemberFloat( const char* name, float f = 0.0f );
	double			GetMemberDouble( const char* name, double d = 0 );
	const char*		GetMemberStr( const char* name, const char* s = "", unsigned int* iLen = NULL );
	void*			GetMemberUserData( const char* name, void* = NULL );
	
	void			SetMemberUserDataLite( const char* name, void* pData );
	void*			GetMemberUserDataLite( const char* name, void* u = NULL );

	void			SetUserData( void* obj, unsigned char type );
	
	bool			isType( int iType );
	bool			isNil();
	bool			isTable();
	bool			isString();
	bool			isNumber();
	bool			isFunction();
	bool			isUserData();

	void			Push();

private:
	CLuaInterface* m_pLua;
	int m_iRef;
};

#endif