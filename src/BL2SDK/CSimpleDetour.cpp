#include "BL2SDK/CSimpleDetour.h"
#include "BL2SDK/Exceptions.h"
#include "BL2SDK/Util.h"

CSimpleDetour::CSimpleDetour(void **old, void *replacement)
{
	m_fnOld = old;
	m_fnReplacement = replacement;
}

bool CSimpleDetour::Attach()
{
	DetourTransactionBegin();
	DetourUpdateThread(GetCurrentThread());

	DetourAttach(m_fnOld, m_fnReplacement);

	LONG result = DetourTransactionCommit();
	if(result != NO_ERROR)
	{
		throw FatalSDKException(4000, Util::Format("Failed to attach detour (Old = 0x%X, Hook = 0x%X, Result = 0x%X)", m_fnOld, m_fnReplacement, result).c_str());
	}

	m_bAttached = true;
}

bool CSimpleDetour::Detach()
{
	if(!m_bAttached)
		return false;

	DetourTransactionBegin();
	DetourUpdateThread(GetCurrentThread());

	DetourDetach(m_fnOld, m_fnReplacement);

	LONG result = DetourTransactionCommit();
	if(result != NO_ERROR)
	{
		throw FatalSDKException(4001, Util::Format("Failed to detach detour (Old = 0x%X, Hook = 0x%X, Result = 0x%X)", m_fnOld, m_fnReplacement, result).c_str());
	}

	m_bAttached = false;
}