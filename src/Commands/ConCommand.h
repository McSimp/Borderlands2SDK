#ifndef CONCOMMAND_H
#define CONCOMMAND_H

#include "Commands/ConCmdManager.h"
#include <string>
#include <vector>

// Borrowed from the Source engine (Please don't sue me gaben)
#define CON_COMMAND( name ) \
   static void name( std::vector<std::string> &args ); \
   static ConCommand name##_command( #name, name ); \
   static void name( std::vector<std::string> &args )


class ConCommand
{
public:
	static std::vector<ConCmdManager::tFuncNameConCmdPair> preloadedCommands;
	static void RegisterCommands();
	ConCommand(const std::string& command, ConCmdManager::tConCommand* func);
};

#endif