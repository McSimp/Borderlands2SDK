#include "BL2SDK/BL2SDK.h"
#include "Logging/Logging.h"
#include "Commands/ConCmdManager.h"

#include <map>
#include <sstream>

namespace ConCmdManager
{
	typedef std::pair<std::string, tConCommand*> tFuncNameConCmdPair;
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

	bool eventConCommand(UObject* pCaller, UFunction* pFunction, void* pParms, void* pResult)
	{
		Logging::Log("[ConCmd] Incoming: pCaller = 0x%X, pFunction = 0x%X, pParms = 0x%X, pResult = 0x%X\n", pCaller, pFunction, pParms, pResult);
		UConsole_eventConsoleCommand_Parms* parms = (UConsole_eventConsoleCommand_Parms*)pParms;
		Logging::Log("[ConCmd] Engine concmd = %ls\n", parms->Command);

		// Because 'say' is appended to everything, take that off
		wchar_t* ptr = parms->Command.Data;
		if(ptr[0] == L's' && ptr[1] == L'a' && ptr[2] == L'y') // HACK. TODO: Fix this
		{
			ptr = ptr + 4;
		}
		Logging::Log("[ConCmd] New command = \"%ls\"\n", ptr);

		// Convert to a normal string because a) I don't give a fuck and b) Lua uses a normal char* for strings
		std::wstring temp(ptr);
		std::string cmdString(temp.begin(), temp.end());

		// Split the command up 
		std::vector<std::string> cmd = split(cmdString, ' ');

		tConCmdMap::iterator iConCommands = ConCommands.find(cmd[0]); // cmd[0] is the command
		if(iConCommands != ConCommands.end())
		{
			iConCommands->second(cmd); // Run the concommand
		}
		else // We don't handle it, maybe the engine does
		{
			Logging::Log("[ConCmd] Command not recognized by SDK, passing to engine\n");
			UWillowConsole* console = (UWillowConsole*)pCaller;
			BL2SDK::InjectedCallNext();
			console->eventConsoleCommand(FString(ptr));
		}

		return false; // Don't run the original event through the engine
	}

	void Initialize()
	{
		// Hook into the engine's concmd system
		BL2SDK::RegisterHook(std::string("Function Engine.Console.ConsoleCommand"), &ConCmdManager::eventConCommand);
	}

	void RegisterCommand(const std::string& command, tConCommand* func)
	{
		tFuncNameConCmdPair pair = std::make_pair(command, func);
		ConCommands.insert(pair);
	}
}