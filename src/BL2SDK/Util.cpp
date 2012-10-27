#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include <string>
#include <stdio.h>
#include <stdarg.h>

namespace Util
{
	std::string Format(const char* fmt, ...)
	{
		std::string str;

		va_list args;
		va_start(args, fmt);

		int buffSize = _vscprintf(fmt, args) + 1;

		if (buffSize <= 1)
			return str;

		char *szBuff = new char[buffSize];
		memset(szBuff, 0, buffSize);

		int len = vsprintf_s(szBuff, buffSize, fmt, args);

		szBuff[buffSize - 1] = 0;

		str = szBuff;
		return str;
	}

	std::wstring Format(const wchar_t* fmt, ...)
	{
		std::wstring str;

		va_list args;
		va_start(args, fmt);

		int buffSize = _vscwprintf(fmt, args) + 1;

		if (buffSize <= 1)
			return str;

		wchar_t* szBuff = new wchar_t[buffSize];
		memset(szBuff, 0, buffSize);

		int len = vswprintf_s(szBuff, buffSize, fmt, args);

		szBuff[buffSize - 1] = 0;

		str = szBuff;
		return str;
	}

	void Popup(const std::wstring &strName, const std::wstring &strText)
	{
		MessageBox(NULL, strText.c_str(), strName.c_str(), MB_OK | MB_ICONASTERISK);
	}
}