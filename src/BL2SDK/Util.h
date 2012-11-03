#ifndef UTIL_H
#define UTIL_H

namespace Util
{
	std::string Format(const char* fmt, ...);
	std::string Format(const char* fmt, va_list args);
	std::wstring Format(const wchar_t* fmt, ...);
	std::wstring Format(const wchar_t* fmt, va_list args);
	std::wstring Widen(const std::string& input);
	std::string Narrow(const std::wstring& input);
	void Popup(const std::wstring& strName, const std::wstring& strText);
	void CloseGame();
}

#endif