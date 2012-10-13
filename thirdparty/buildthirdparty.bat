REM Setup dev environment (assuming VS 2012 for the moment, write a proper batch file later))
call "%VS110COMNTOOLS%\VsDevCmd.bat"

REM Cleanup Crashrpt
REM rmdir /S /Q "crashrpt\bin"
REM call "crashrpt\clean.bat"
del "..\bin\Debug\CrashRpt1400d.dll"
del "..\bin\Release\CrashRpt1400.dll"
del "..\lib\CrashRpt1400*.lib"

REM Build Crashrpt in Debug and Release
MSBuild "crashrpt\CrashRpt_vs2010.sln" /t:Clean
MSBuild "crashrpt\CrashRpt_vs2010.sln" /m /p:Configuration=Debug
MSBuild "crashrpt\CrashRpt_vs2010.sln" /m /p:Configuration=Release

REM Copy the important bits of its output to the bin folder for the SDK
copy "crashrpt\bin\CrashRpt1400d.dll" "..\bin\Debug\CrashRpt1400d.dll"
copy "crashrpt\bin\CrashRpt1400.dll" "..\bin\Release\CrashRpt1400.dll"

copy "crashrpt\bin\crashrpt_lang.ini" "..\bin\Debug\crashrpt_lang.ini"
copy "crashrpt\bin\crashrpt_lang.ini" "..\bin\Release\crashrpt_lang.ini"

copy "crashrpt\bin\CrashSender1400d.exe" "..\bin\Debug\CrashSender1400d.exe"
copy "crashrpt\bin\CrashSender1400.exe" "..\bin\Release\CrashSender1400.exe"

copy "crashrpt\lib\CrashRpt1400*.lib" "..\lib\CrashRpt1400*.lib"