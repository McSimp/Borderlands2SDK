#ifndef UTIL_H
#define UTIL_H

namespace Util
{
	std::string Format(const char* fmt, ...);
	std::wstring Format(const wchar_t* fmt, ...);
	void Popup(const std::wstring &strName, const std::wstring &strText);
}

#endif