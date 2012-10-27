#ifndef SIGSCAN_H
#define SIGSCAN_H

#define WIN32_LEAN_AND_MEAN
#include <windows.h>

class CSigScan 
{
private:
    unsigned char* m_pModuleBase;
    size_t m_moduleLen;
	HMODULE m_moduleHandle;
	bool m_isReady;

public:
	CSigScan(wchar_t* moduleName);

	void* Scan(unsigned char* sig, char* mask, int sigLength);
	void* Scan(unsigned char* sig, char* mask);

	bool IsReady() { return m_isReady; }
};
#endif