#include "BL2SDK/BL2SDK.h"
#include "BL2SDK/Logging.h"
#include "Commands/ConCommand.h"

#include <iterator>
#include <sstream>

CON_COMMAND(l)
{
	std::stringstream ss;
	std::copy(args.begin()+1, args.end(), std::ostream_iterator<std::string>(ss, " "));
	std::string result = ss.str(); // There's a trailing space but lua shouldn't give a shit

	BL2SDK::Lua->RunString(result.c_str());
}

CON_COMMAND(lo)
{
	std::stringstream ss;
	std::copy(args.begin()+1, args.end(), std::ostream_iterator<std::string>(ss, " "));
	std::string result = ss.str(); // There's a trailing space but lua shouldn't give a shit

	BL2SDK::Lua->DoFile(result.c_str());
}

CON_COMMAND(ResetLua)
{
	delete BL2SDK::Lua;
	BL2SDK::Lua = new CLuaInterface();
	BL2SDK::Lua->InitializeModules();
}