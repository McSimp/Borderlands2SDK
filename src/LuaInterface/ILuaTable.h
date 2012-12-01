#ifndef ILUATABLE_H
#define ILUATABLE_H

class CLuaObject;

struct LuaKeyValue
{
	CLuaObject* pKey;
	CLuaObject* pValue;
};

#include <vector>
typedef std::vector<LuaKeyValue> CUtlLuaVector;

#define FOR_LOOP( vecName, iteratorName ) \
for ( unsigned int iteratorName = 0; iteratorName < vecName->size(); iteratorName++ )

#endif