#include "BL2SDK/CSigScan.h"
#include "BL2SDK/Exceptions.h"
#include "BL2SDK/Util.h"

// Based off CSigScan from AlliedModders

CSigScan::CSigScan(wchar_t* moduleName)
{
	m_moduleHandle = GetModuleHandle(moduleName);
	if(m_moduleHandle == NULL)
	{
		throw FatalSDKException(3000, Util::Format("Sigscan failed (GetModuleHandle returned NULL, Error = 0x%X)", GetLastError()).c_str());
	}

	void* pAddr = m_moduleHandle;
 
    MEMORY_BASIC_INFORMATION mem;
 
    if(!VirtualQuery(pAddr, &mem, sizeof(mem)))
	{
		throw FatalSDKException(3001, Util::Format("Sigscan failed (VirtualQuery returned NULL, Error = 0x%X)", GetLastError()).c_str());
	}
 
	m_pModuleBase = (unsigned char*)mem.AllocationBase;
	if(m_pModuleBase == NULL)
	{
		throw FatalSDKException(3002, "Sigscan failed (mem.AllocationBase was NULL)");
	}

    IMAGE_DOS_HEADER* dos = (IMAGE_DOS_HEADER*)mem.AllocationBase;
    IMAGE_NT_HEADERS* pe = (IMAGE_NT_HEADERS*)((unsigned long)dos+(unsigned long)dos->e_lfanew);
 
    if(pe->Signature != IMAGE_NT_SIGNATURE)
	{
		throw FatalSDKException(3003, "Sigscan failed (pe points to a bad location)");
	}
 
	m_moduleLen = (size_t)pe->OptionalHeader.SizeOfImage;
}

void* CSigScan::Scan(unsigned char* sig, char* mask)
{
	int sigLength = strlen(mask);
	return Scan(sig, mask, sigLength);
}

void* CSigScan::Scan(unsigned char* sig, char* mask, int sigLength)
{
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

	throw FatalSDKException(3010, Util::Format("Sigscan failed (Signature not found, Mask = %s)", mask).c_str());
}
