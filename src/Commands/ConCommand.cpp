#include "Commands/ConCommand.h"

std::vector<ConCmdManager::tFuncNameConCmdPair> ConCommand::preloadedCommands = std::vector<ConCmdManager::tFuncNameConCmdPair>();

ConCommand::ConCommand(const std::string& command, ConCmdManager::tConCommand* func)
{
	ConCmdManager::tFuncNameConCmdPair pair = std::make_pair(command, func);
	this->preloadedCommands.push_back(pair);
}

// This is basically so I can have CON_COMMAND() scattered about the place, using
// the global constructor without the DLL injector throwing a hissy fit.
void ConCommand::RegisterCommands()
{
	std::vector<ConCmdManager::tFuncNameConCmdPair>::iterator it;
	for(it = preloadedCommands.begin(); it != preloadedCommands.end(); it++)
	{
		ConCmdManager::RegisterCommand((ConCmdManager::tFuncNameConCmdPair)*it);
	}
}