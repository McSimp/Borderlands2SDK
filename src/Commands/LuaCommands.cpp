#include "BL2SDK/BL2SDK.h"
#include "BL2SDK/Logging.h"
#include "Commands/ConCommand.h"
#include "LuaInterface/LuaManager.h"

#include <iterator>
#include <sstream>

using LuaManager::g_Lua;

CON_COMMAND(l)
{
	std::stringstream ss;
	std::copy(args.begin()+1, args.end(), std::ostream_iterator<std::string>(ss, " "));
	std::string result = ss.str(); // There's a trailing space but lua shouldn't give a shit

	g_Lua->RunString(result.c_str());
}

CON_COMMAND(lo)
{
	std::stringstream ss;
	std::copy(args.begin()+1, args.end(), std::ostream_iterator<std::string>(ss, " "));
	std::string result = ss.str(); // There's a trailing space but lua shouldn't give a shit

	g_Lua->DoFile(result.c_str());
}