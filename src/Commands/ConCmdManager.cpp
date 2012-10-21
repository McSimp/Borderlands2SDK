#include "BL2SDK/BL2SDK.h"
#include "Logging/Logging.h"
#include "Commands/ConCmdManager.h"
#include "Commands/ConCommand.h"
#include "LuaInterface/LuaInterface.h"

#include <map>
#include <sstream>

using LuaInterface::Lua;

namespace ConCmdManager
{
	typedef std::map<std::string, tConCommand*> tConCmdMap;
	tConCmdMap ConCommands;

	tArgsList &split(const std::string &s, char delim, tArgsList &elems) {
		std::stringstream ss(s);
		std::string item;
		while(std::getline(ss, item, delim)) {
			elems.push_back(item);
		}
		return elems;
	}

	tArgsList split(const std::string &s, char delim) {
		tArgsList elems;
		return split(s, delim, elems);
	}

	bool issueLuaCommand(const std::vector<std::string> &args)
	{
		// Get the InjectConsoleCommand func and call it
		lua_getglobal(Lua(), "InjectConsoleCommand");
		
		// Push the command name
		lua_pushlstring(Lua(), args[0].c_str(), args[0].size());

		// Create the args table
		lua_newtable(Lua());
		int top = lua_gettop(Lua());

		for(unsigned int i = 0; i < args.size(); i++)
		{
			lua_pushnumber(Lua(), i+1);
			lua_pushlstring(Lua(), args[i].c_str(), args[i].size());
			lua_settable(Lua(), top);
		}

		lua_call(Lua(), 2, 1);

		bool result = (bool)lua_toboolean(Lua(), -1);
		lua_pop(Lua(), 1);

		return result;
	}

	bool eventConCommand(UObject* pCaller, UFunction* pFunction, void* pParms, void* pResult)
	{
		UWillowConsole* console = (UWillowConsole*)pCaller;
		
		UConsole_eventConsoleCommand_Parms* parms = (UConsole_eventConsoleCommand_Parms*)pParms;
		//Logging::Log("[ConCmd] Engine concmd = %ls\n", parms->Command);

		// Because 'say' is appended to everything, take that off
		wchar_t* ptr = parms->Command.Data;
		if(ptr[0] == L's' && ptr[1] == L'a' && ptr[2] == L'y') // HACK. TODO: Fix this
		{
			ptr = ptr + 4;
		}
		//Logging::Log("[ConCmd] New command = \"%ls\"\n", ptr);

		// Convert to a normal string because #1 I don't give a fuck and #2 That's terror
		std::wstring temp(ptr);
		std::string cmdString(temp.begin(), temp.end());

		// Split the command up 
		std::vector<std::string> cmd = split(cmdString, ' ');

		tConCmdMap::iterator iConCommands = ConCommands.find(cmd[0]); // cmd[0] is the command
		if(iConCommands != ConCommands.end())
		{
			// My god UTF-16 is the biggest PITA
			std::wstringstream s;
			s << L"\n>>> " << temp.c_str() << L" <<<\n"; 

			BL2SDK::InjectedCallNext();
			console->eventOutputText(FString((wchar_t*)s.str().c_str()));
			iConCommands->second(cmd); // Run the concommand
		}
		else if(!issueLuaCommand(cmd)) // Maybe Lua handles it, it'll do it's thing
		{
			Logging::Log("[ConCmd] Command not recognized by SDK, passing to engine\n");
			BL2SDK::InjectedCallNext();
			console->eventConsoleCommand(FString(ptr));
		}

		return false; // Don't run the original event through the engine
	}

	void Initialize()
	{
		// Hook into the engine's concmd system
		BL2SDK::RegisterHook(std::string("Function Engine.Console.ConsoleCommand"), &ConCmdManager::eventConCommand);
		ConCommand::RegisterCommands();
	}

	void RegisterCommand(const std::string& command, tConCommand* func)
	{
		tFuncNameConCmdPair pair = std::make_pair(command, func);
		ConCommands.insert(pair);
	}

	void RegisterCommand(const tFuncNameConCmdPair& pair)
	{
		ConCommands.insert(pair);
	}
}