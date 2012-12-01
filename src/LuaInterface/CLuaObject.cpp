// This file is based on garry's implementation as well as BlackAwps' backwards headers
#include "LuaInterface/CLuaObject.h"
#include "LuaInterface/UserData.h"
#include <sstream>

CLuaObject::CLuaObject( CLuaInterface* lua, int iRef ) : m_pLua(lua), m_iRef(iRef)
{
}

CLuaObject::CLuaObject( CLuaInterface* lua, CLuaObject* obj ) : m_pLua(lua), m_iRef(obj->m_iRef)
{
}

CLuaObject::~CLuaObject()
{
}

void CLuaObject::Set( CLuaObject* obj ) // ???
{
	if ( m_iRef )
		m_pLua->FreeReference( m_iRef );
		
	m_pLua->PushReference( obj->m_iRef );
	m_iRef = m_pLua->CreateReference();
}

void CLuaObject::SetNil() // ???
{
	m_pLua->PushNil();
	SetFromStack( -1 );

}

void CLuaObject::SetFromStack( int i ) // ???
{
	if ( m_iRef )
		m_pLua->FreeReference( m_iRef );
		
	m_pLua->Push( i );
	m_iRef = m_pLua->CreateReference();
}

void CLuaObject::UnReference()
{
	m_pLua->FreeReference( m_iRef );
	delete this;
}

int CLuaObject::GetReference()
{
	return m_iRef;
}

int CLuaObject::GetType()
{
	Push(); // +1
		int ret = m_pLua->GetType( -1 );
	m_pLua->Pop(); // -1
	return ret;
}

const char* CLuaObject::GetTypeName()
{
	Push(); // +1
		const char* ret = m_pLua->GetTypeName( m_pLua->GetType( -1 ) );
	m_pLua->Pop(); // -1
	return ret;
}

const char* CLuaObject::GetString( unsigned int* iLen )
{
	Push(); // +1
		const char* ret = m_pLua->GetString( -1, iLen );
	m_pLua->Pop(); // -1
	return ret;
}

int CLuaObject::GetInt( void )
{
	Push(); // +1
		int ret = (int) m_pLua->GetNumber( -1 );
	m_pLua->Pop(); // -1
	return ret;
}

double CLuaObject::GetDouble( void )
{
	Push(); // +1
		double ret = m_pLua->GetNumber( -1 );
	m_pLua->Pop(); // -1
	return ret;
}

float CLuaObject::GetFloat( void )
{
	Push(); // +1
		float ret = (float) m_pLua->GetNumber( -1 );
	m_pLua->Pop(); // -1
	return ret;
}

bool CLuaObject::GetBool( void )
{
	Push(); // +1
		bool ret = m_pLua->GetBool( -1 );
	m_pLua->Pop(); // -1
	return ret;
}

void* CLuaObject::GetUserData( void )
{
	Push(); // +1
		UserData* data = (UserData*) m_pLua->GetUserData( -1 );
	m_pLua->Pop(); // -1
	return data->data;
}

CUtlLuaVector* CLuaObject::GetMembers()
{
	Push();

	if( m_pLua->GetType( -1 ) != Lua::TYPE_TABLE )
    {
		m_pLua->ThrowError( "ILuaObject::GetMembers, object not a table!" );
        return NULL;
    }

	CUtlLuaVector* tableMembers = new CUtlLuaVector();

	m_pLua->PushNil();
	while ( m_pLua->Next( -2 ) != 0 )
	{
		LuaKeyValue keyValues;

		int iValue = m_pLua->CreateReference();
		int iKey = m_pLua->CreateReference();
		
		keyValues.pValue = new CLuaObject( m_pLua, iValue ); // -1
		keyValues.pKey = new CLuaObject( m_pLua, iKey ); // -2

		tableMembers->push_back( keyValues );
		
		m_pLua->PushReference( iKey ); // Push key back for next loop

	}
	
	m_pLua->Pop();

	return tableMembers;
}

void CLuaObject::SetMember( const char* name )
{
	Push(); // +1
		m_pLua->Push( name ); // +1
		m_pLua->PushNil(); // +1
		m_pLua->SetTable( -3 ); // +2
	m_pLua->Pop(); // -1
}

void CLuaObject::SetMember( const char* name, CLuaObject* obj )
{
	Push(); // +1
		m_pLua->Push( name ); // +1
		obj->Push(); // +1
		m_pLua->SetTable( -3 ); // -2
	m_pLua->Pop(); // -1
}

void CLuaObject::SetMember( const char* name, double d )
{
	Push(); // +1
		m_pLua->Push( name ); // +1
		m_pLua->Push( d ); // +1
		m_pLua->SetTable( -3 ); // -2
	m_pLua->Pop(); // -1
}

void CLuaObject::SetMember( const char* name, bool b )
{
	Push(); // +1
		m_pLua->Push( name ); // +1
		m_pLua->Push( b ); // +1
		m_pLua->SetTable( -3 ); // -2
	m_pLua->Pop(); // -1
}

void CLuaObject::SetMember( const char* name, const char* s, unsigned int iLen )
{
	Push(); // +1
		m_pLua->Push( name ); // +1
		m_pLua->Push( s, iLen ); // +1
		m_pLua->SetTable( -3 ); // -2
	m_pLua->Pop(); // -1
}

void CLuaObject::SetMember( const char* name, lua_CFunction f )
{
	Push(); // +1
		m_pLua->Push( name ); // +1
		m_pLua->Push( f ); // +1
		m_pLua->SetTable( -3 ); // -2
	m_pLua->Pop(); // -1
}

void CLuaObject::SetMember( double dKey )
{
	Push(); // +1
		m_pLua->Push( dKey ); // +1
		m_pLua->PushNil(); // +1
		m_pLua->SetTable( -3 ); // -2
	m_pLua->Pop(); // -1
}

void CLuaObject::SetMember( double dKey, CLuaObject* obj )
{
	Push(); // +1
		m_pLua->Push( dKey ); // +1
		obj->Push(); // +1
		m_pLua->SetTable( -3 ); // -2
	m_pLua->Pop(); // -1
}

void CLuaObject::SetMember( double dKey, double d )
{
	Push(); // +1
		m_pLua->Push( dKey ); // +1
		m_pLua->Push( d ); // +1
		m_pLua->SetTable( -3 ); // -2
	m_pLua->Pop(); // -1
}

void CLuaObject::SetMember( double dKey, bool b )
{
	Push(); // +1
		m_pLua->Push( dKey ); // +1
		m_pLua->Push( b ); // +1
		m_pLua->SetTable( -3 ); // -2
	m_pLua->Pop(); // -1
}

void CLuaObject::SetMember( double dKey, const char* s, unsigned int iLen )
{
	Push(); // +1
		m_pLua->Push( dKey ); // +1
		m_pLua->Push( s, iLen ); // +1
		m_pLua->SetTable( -3 ); // -2
	m_pLua->Pop(); // -1
}

void CLuaObject::SetMember( double dKey, lua_CFunction f )
{
	Push(); // +1
		m_pLua->Push( dKey ); // +1
		m_pLua->Push( f ); // +1
		m_pLua->SetTable( -3 ); // -2
	m_pLua->Pop(); // -1
}

void CLuaObject::SetMember( float fKey )
{
	SetMember( (double) fKey );
}

void CLuaObject::SetMember( float fKey, CLuaObject* obj )
{
	SetMember( (double) fKey, obj );
}

void CLuaObject::SetMember( float fKey, double d )
{
	SetMember( (double) fKey, d );
}

void CLuaObject::SetMember( float fKey, bool b )
{
	SetMember( (double) fKey, b );
}

void CLuaObject::SetMember( float fKey, const char* s, unsigned int iLen )
{
	SetMember( (double) fKey, s, iLen );
}

void CLuaObject::SetMember( float fKey, lua_CFunction f )
{
	SetMember( (double) fKey, f );
}

void CLuaObject::SetMember( int iKey )
{
	SetMember( (double) iKey );
}

void CLuaObject::SetMember( int iKey, CLuaObject* obj )
{
	SetMember( (double) iKey, obj );
}

void CLuaObject::SetMember( int iKey, double d )
{
	SetMember( (double) iKey, d );
}

void CLuaObject::SetMember( int iKey, bool b )
{
	SetMember( (double) iKey, b );
}

void CLuaObject::SetMember( int iKey, const char* s, unsigned int iLen )
{
	SetMember( (double) iKey, s, iLen );
}

void CLuaObject::SetMember( int iKey, lua_CFunction f )
{
	SetMember( (double) iKey, f );
}

CLuaObject* CLuaObject::GetMember( const char* name )
{
	Push(); // +1
		m_pLua->GetField( -1, name ); // +1
		CLuaObject* r = new CLuaObject( m_pLua, m_pLua->CreateReference() ); // -1
	m_pLua->Pop(); // -1
	return r;
}

CLuaObject* CLuaObject::GetMember( double dKey )
{
	Push(); // +1
		m_pLua->Push( dKey ); // +1
		m_pLua->GetTable( -2 );
		CLuaObject* r = new CLuaObject( m_pLua, m_pLua->CreateReference() ); // -1
	m_pLua->Pop(); // -1
	return r;
}

CLuaObject* CLuaObject::GetMember( float fKey )
{
	return GetMember( (double) fKey );
}

CLuaObject* CLuaObject::GetMember( int iKey )
{
	return GetMember( (double) iKey );
}

CLuaObject* CLuaObject::GetMember( CLuaObject* oKey )
{
	Push(); // +1
		oKey->Push(); // +1
		m_pLua->GetTable( -2 ); // -2 AND +1
		CLuaObject* r = new CLuaObject( m_pLua, m_pLua->CreateReference() ); // -1
	m_pLua->Pop(); // -1
	return r;
}

bool CLuaObject::GetMemberBool( const char* name, bool b )
{
	Push(); // +1
		m_pLua->GetField( -1, name ); // +1
		bool r = ( m_pLua->GetType(-1) != Lua::TYPE_NIL ) ? m_pLua->GetBool(-1) : b;
	m_pLua->Pop(2); // -2
	return r;
}

int CLuaObject::GetMemberInt( const char* name, int i )
{
	return (int) GetMemberDouble( name, (int) i );
}

float CLuaObject::GetMemberFloat( const char* name, float f )
{
	return (float) GetMemberDouble( name, (double) f );
}

double CLuaObject::GetMemberDouble( const char* name, double d )
{
	Push(); // +1
		m_pLua->GetField( -1, name ); // +1
		double r = ( m_pLua->GetType(-1) != Lua::TYPE_NIL ) ? m_pLua->GetNumber(-1) : d;
	m_pLua->Pop(2); // -2
	return r;
}

const char* CLuaObject::GetMemberStr( const char* name, const char* s, unsigned int* iLen )
{
	Push(); // +1
		m_pLua->GetField( -1, name ); // +1
		const char* r = ( m_pLua->GetType(-1) != Lua::TYPE_NIL ) ? m_pLua->GetString(-1, iLen) : s;
	m_pLua->Pop(2); // -2
	return r;
}

void* CLuaObject::GetMemberUserData( const char* name, void* u )
{
	Push(); // +1
		m_pLua->GetField( -1, name ); // +1
		void* r = ( m_pLua->GetType(-1) != Lua::TYPE_NIL ) ? m_pLua->GetUserData(-1) : u;
	m_pLua->Pop(2); // -2
	return r;
}

void CLuaObject::SetUserData( void* obj, unsigned char type )
{
	Push(); // +1
		UserData *data = (UserData*) m_pLua->GetUserData();

		data->data = obj;
		data->type = type;
	m_pLua->Pop(); // -1
}

void CLuaObject::SetMemberUserDataLite( const char* name, void* pData )
{
	Push(); // +1
		m_pLua->Push( name ); // +1
		m_pLua->PushUserData( pData ); // +1
		m_pLua->SetTable( -3 ); // -2
	m_pLua->Pop(); // -1
}

void* CLuaObject::GetMemberUserDataLite( const char* name, void* u )
{
	Push(); // +1
		m_pLua->GetField( -1, name ); // +1
		void* r  = ( m_pLua->GetType(-1) != Lua::TYPE_NIL ) ? m_pLua->GetUserData(-1) : u;
	m_pLua->Pop(2); // -2
	return r;
}

bool CLuaObject::isType( int iType )
{
	Push(); // +1
		bool ret = m_pLua->IsType( -1, iType );
	m_pLua->Pop(); // -1
	return ret;
}

bool CLuaObject::isNil()
{
	return isType( Lua::TYPE_NIL );
}

bool CLuaObject::isTable()
{
	return isType( Lua::TYPE_TABLE );
}

bool CLuaObject::isString()
{
	return isType( Lua::TYPE_STRING );
}

bool CLuaObject::isNumber()
{
	return isType( Lua::TYPE_NUMBER );
}

bool CLuaObject::isFunction()
{
	return isType( Lua::TYPE_FUNCTION );
}

bool CLuaObject::isUserData()
{
	Push(); // +1
		int iType = m_pLua->GetType( -1 );
	m_pLua->Pop(); // -1

	return iType == Lua::TYPE_USERDATA || iType > Lua::TYPE_COUNT;
}

void CLuaObject::Push()
{
	m_pLua->PushReference( m_iRef );
}


