#ifndef CRASHRPTHELPER_H
#define CRASHRPTHELPER_H

#include "crashrpt/include/CrashRpt.h"
namespace CrashRptHelper
{
	bool Initialize();
	void Cleanup();
	void SoftCrash(int code);
	bool GenerateReport(unsigned int code, PEXCEPTION_POINTERS ep);
	void AddProperty(const std::wstring& propertyName, const std::wstring& value);
}

#endif