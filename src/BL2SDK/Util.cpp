#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include <string>
#include <stdio.h>
#include <stdarg.h>
#include "BL2SDK/Util.h"

namespace Util
{
	std::string Format(const char* fmt, ...)
	{
		va_list args;
		va_start(args, fmt);
		std::string formatted = Format(fmt, args);
		va_end(args);

		return formatted;
	}

	std::string Format(const char* fmt, va_list args)
	{
		std::string str;

		int buffSize = _vscprintf(fmt, args) + 1;

		if (buffSize <= 1)
			return str;

		char *szBuff = new char[buffSize];
		memset(szBuff, 0, buffSize);

		int len = vsprintf_s(szBuff, buffSize, fmt, args);

		szBuff[buffSize - 1] = 0;

		str = szBuff;
		delete[] szBuff;

		return str;
	}

	std::wstring Format(const wchar_t* fmt, ...)
	{
		va_list args;
		va_start(args, fmt);
		std::wstring formatted = Format(fmt, args);
		va_end(args);

		return formatted;
	}

	std::wstring Format(const wchar_t* fmt, va_list args)
	{
		std::wstring str;

		int buffSize = _vscwprintf(fmt, args) + 1;

		if (buffSize <= 1)
			return str;

		wchar_t* szBuff = new wchar_t[buffSize];
		memset(szBuff, 0, buffSize);

		int len = vswprintf_s(szBuff, buffSize, fmt, args);

		szBuff[buffSize - 1] = 0;

		str = szBuff;
		delete[] szBuff;

		return str;
	}

	// TODO: Benchmarking and whatnot to see how these perform
	std::wstring Widen(const std::string& input)
	{
		std::wstring out;
		out.assign(input.begin(), input.end());
		return out; 
	}

	std::string Narrow(const std::wstring& input)
	{
		std::string out;
		out.assign(input.begin(), input.end());
		return out;
	}

	void Popup(const std::wstring& strName, const std::wstring& strText)
	{
		MessageBox(NULL, strText.c_str(), strName.c_str(), MB_OK | MB_ICONASTERISK);
	}

	void CloseGame()
	{
		TerminateProcess(GetCurrentProcess(), 1);
	}
}