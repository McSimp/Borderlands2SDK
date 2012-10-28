#include "BL2SDK/CSimpleDetour.h"

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

	m_bAttached = (DetourTransactionCommit() == NO_ERROR);
	return m_bAttached;
}

bool CSimpleDetour::Detach()
{
	if(!m_bAttached)
		return false;

	DetourTransactionBegin();
	DetourUpdateThread(GetCurrentThread());

	DetourDetach(m_fnOld, m_fnReplacement);

	return (DetourTransactionCommit() == NO_ERROR);
}