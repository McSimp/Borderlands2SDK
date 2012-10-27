#ifndef CRASHRPTHELPER_H
#define CRASHRPTHELPER_H

#include "crashrpt/include/CrashRpt.h"
namespace CrashRptHelper
{
	bool Initialize();
	void Cleanup();
	//int InstallThread();
	bool SoftCrash();
	bool GenerateReport(unsigned int code, PEXCEPTION_POINTERS ep);
}

#endif