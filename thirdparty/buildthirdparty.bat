@echo off
REM Setup dev environment (assuming VS 2012 for the moment, write a proper batch file later)
echo "Setting dev environment"
call "%VS110COMNTOOLS%\VsDevCmd.bat"

REM Cleanup Crashrpt
REM rmdir /S /Q "crashrpt\bin"
REM call "crashrpt\clean.bat"
echo "Cleaning up Crashrpt from SDK"
del "..\bin\Debug\CrashRpt1400d.dll"
del "..\bin\Release\CrashRpt1400.dll"
del "..\bin\Debug\crashrpt_lang.ini"
del "..\bin\Release\crashrpt_lang.ini"
del "..\bin\Debug\CrashSender1400d.exe"
del "..\bin\Release\CrashSender1400.exe"
del "..\lib\CrashRpt1400*.lib"

REM Build Crashrpt in Debug and Release
echo "Building Crashrpt"
MSBuild "crashrpt\CrashRpt_vs2010.sln" /t:Clean
MSBuild "crashrpt\CrashRpt_vs2010.sln" /m /p:Configuration=Debug
MSBuild "crashrpt\CrashRpt_vs2010.sln" /m /p:Configuration=Release

REM Copy the important bits of its output to the bin folder for the SDK
echo "Exporting built files to SDK"

copy "crashrpt\bin\CrashRpt1400d.dll" "..\bin\Debug\CrashRpt1400d.dll"
copy "crashrpt\bin\CrashRpt1400.dll" "..\bin\Release\CrashRpt1400.dll"

copy "crashrpt\bin\crashrpt_lang.ini" "..\bin\Debug\crashrpt_lang.ini"
copy "crashrpt\bin\crashrpt_lang.ini" "..\bin\Release\crashrpt_lang.ini"

copy "crashrpt\bin\CrashSender1400d.exe" "..\bin\Debug\CrashSender1400d.exe"
copy "crashrpt\bin\CrashSender1400.exe" "..\bin\Release\CrashSender1400.exe"

copy "crashrpt\lib\CrashRpt1400*.lib" "..\lib\CrashRpt1400*.lib"

REM Check if GWEN project files have been created, create if needed
echo "Checking for GWEN project files"
if not exist "gwen\gwen\Projects\windows" (
	echo "Creating GWEN project files"
	call "gwen\gwen\Projects\Build.bat"
)

REM Cleanup GWEN files in SDK
echo "Cleaning up GWEN from SDK"
del "..\lib\gwen_staticd.lib"
del "..\lib\gwen_static.lib"

rmdir /S /Q "gwen\gwen\lib\windows\vs2010"

REM Build GWEN in Debug and Release
echo "Building GWEN"
MSBuild "gwen\gwen\Projects\windows\vs2010\GWEN-Static.vcxproj" /t:Clean
MSBuild "gwen\gwen\Projects\windows\vs2010\GWEN-Static.vcxproj" /m /p:Configuration=Debug
MSBuild "gwen\gwen\Projects\windows\vs2010\GWEN-Static.vcxproj" /m /p:Configuration=Release

REM Copy into SDK
echo "Exporting built files to SDK"
copy "gwen\gwen\lib\windows\vs2010\gwen_staticd" "..\lib\gwen_staticd.lib"
copy "gwen\gwen\lib\windows\vs2010\gwen_static.lib" "..\lib\gwen_static.lib"
