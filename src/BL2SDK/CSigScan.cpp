#include "BL2SDK/CSigScan.h"

// Based off CSigScan from AlliedModders

CSigScan::CSigScan(wchar_t* moduleName)
{
	m_isReady = false;
	m_moduleHandle = GetModuleHandle(moduleName);
	if(m_moduleHandle == NULL)
		return;

	void* pAddr = m_moduleHandle;
 
    MEMORY_BASIC_INFORMATION mem;
 
    if(!VirtualQuery(pAddr, &mem, sizeof(mem)))
        return;
 
	m_pModuleBase = (unsigned char*)mem.AllocationBase;
	if(m_pModuleBase == NULL)
		return;

    IMAGE_DOS_HEADER* dos = (IMAGE_DOS_HEADER*)mem.AllocationBase;
    IMAGE_NT_HEADERS* pe = (IMAGE_NT_HEADERS*)((unsigned long)dos+(unsigned long)dos->e_lfanew);
 
    if(pe->Signature != IMAGE_NT_SIGNATURE)
        return; // Constructor failed: pe points to a bad location
 
	m_moduleLen = (size_t)pe->OptionalHeader.SizeOfImage;

	m_isReady = true;
}

void* CSigScan::Scan(unsigned char* sig, char* mask)
{
	int sigLength = strlen(mask);
	return Scan(sig, mask, sigLength);
}

void* CSigScan::Scan(unsigned char* sig, char* mask, int sigLength)
{
	if(!m_isReady)
		return NULL;

	unsigned char *pData = m_pModuleBase;
	unsigned char *pEnd = m_pModuleBase + m_moduleLen;

    while(pData < pEnd) 
	{
		int i;
        for(i = 0; i < sigLength; i++)
		{
            if(mask[i] != '?' && sig[i] != pData[i])
                break;
        }

		// The for loop finished on its own accord
        if(i == sigLength)
		{            
			return (void*)pData;
		}

        pData++;
    }

	return NULL;
}
