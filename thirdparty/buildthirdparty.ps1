# Some parts stolen from http://www.timvw.be/2010/11/17/configure-visual-studio-2010-environment-in-powershell/
$ErrorActionPreference = "Stop"

function Get-Batchfile($file) 
{
	$cmd = "`"$file`" & set"
	cmd /c `"$cmd`" | Foreach-Object {
		$p, $v = $_.split('=')
		Set-Item -path env:$p -value $v
	}
}

function VS-Env($envvar, $name, $toolset)
{
	if(!(Test-Path "env:\$envvar")) # This VS environment variable doesn't exist
	{
		$Host.UI.WriteErrorLine("$name tools not found")
		return $false
	}
	
	$comntools = (Get-ChildItem env:$envvar).Value
	$BatchFile = [System.IO.Path]::Combine($comntools, "vsvars32.bat")
	if(!(Test-Path $BatchFile))
	{
		$Host.UI.WriteErrorLine("$name tools not found")
		return $false
	}
	
	Write-Host $name "tools found, loading environment variables..."
	Get-Batchfile $BatchFile
	Write-Host "Environment variables loaded successfully"
	
	Set-Variable "PlatformToolset" $toolset -scope "Global"
	Write-Host "Platform toolset set to $PlatformToolset"

	return $true
}

function Log-Action($act)
{
	Write-Host "`n" $act "`n" -foregroundcolor yellow -backgroundcolor black
}

function Cleanup-File($path)
{
	try
	{
		Remove-Item $path
		Write-Host $path "deleted"
	}
	catch [Exception]
	{
		Write-Host $path "not found"
	}
}

function Copy-Built-File($path, $to)
{
	try
	{
		Copy-Item $path $to
		Write-Host $path "copied"
	}
	catch [Exception]
	{
		$Host.UI.WriteErrorLine("$path not found. This indicates that the build script is out of date and needs to be updated.")
		Exit
	}
}

function Run-MSBuild($sln, $config, $params)
{
	$cmd = "MSBuild $sln /p:Configuration=$config;PlatformToolset=$PlatformToolset $params"
	#Invoke-Expression $cmd
	cmd /c `"$cmd`"

	if($LASTEXITCODE -ne 0)
	{
		$Host.UI.WriteErrorLine("`nMSBuild failed on $sln (Cmd = $cmd).")
		Exit
	}
}

Log-Action "Setting Visual Studio environment..."
if((!(VS-Env VS110COMNTOOLS "Visual Studio 2012" "v110")) -and (!(VS-Env VS100COMNTOOLS "Visual Studio 2010" "v100")))
{
	$Host.UI.WriteErrorLine("Failed to determine Visual Studio tools path. Make sure you have VS2010 or VS2012 installed.")
	Exit
}

Log-Action "Removing LuaJIT from SDK..."
Cleanup-File "..\lib\lua51.lib"

Log-Action "Building LuaJIT..."
Push-Location LuaJIT\src
cmd /c "msvcbuild.bat static"
Pop-Location

Log-Action "Moving built files to SDK..."
Copy-Built-File "LuaJIT\src\lua51.lib" "..\lib\lua51.lib"

Log-Action "Removing Crashrpt from SDK..."
Cleanup-File "..\bin\Debug\CrashRpt1402d.dll"
Cleanup-File "..\bin\Release\CrashRpt1402.dll"
Cleanup-File "..\bin\Debug\crashrpt_lang.ini"
Cleanup-File "..\bin\Release\crashrpt_lang.ini"
Cleanup-File "..\bin\Debug\CrashSender1402d.exe"
Cleanup-File "..\bin\Release\CrashSender1402.exe"
Cleanup-File "..\lib\CrashRpt1402.lib"
Cleanup-File "..\lib\CrashRpt1402d.lib"

Log-Action "Cleaning CrashRpt solution..."
Run-MSBuild "crashrpt\CrashRpt_vs2010.sln" "Debug" "/t:Clean /m"
Run-MSBuild "crashrpt\CrashRpt_vs2010.sln" "Release" "/t:Clean /m"

Log-Action "Building CrashRpt in Debug..."
Run-MSBuild "crashrpt\CrashRpt_vs2010.sln" "Debug" "/m"

Log-Action "Building CrashRpt in Release..." 
Run-MSBuild "crashrpt\CrashRpt_vs2010.sln" "Release" "/m"

Log-Action "Moving built files to SDK..."
Copy-Built-File "crashrpt\bin\CrashRpt1402d.dll" "..\bin\Debug\CrashRpt1402d.dll"
Copy-Built-File "crashrpt\bin\CrashRpt1402.dll" "..\bin\Release\CrashRpt1402.dll"

Copy-Built-File "crashrpt\lang_files\crashrpt_lang_EN.ini" "..\bin\Debug\crashrpt_lang.ini"
Copy-Built-File "crashrpt\lang_files\crashrpt_lang_EN.ini" "..\bin\Release\crashrpt_lang.ini"

Copy-Built-File "crashrpt\bin\CrashSender1402d.exe" "..\bin\Debug\CrashSender1402d.exe"
Copy-Built-File "crashrpt\bin\CrashSender1402.exe" "..\bin\Release\CrashSender1402.exe"

Copy-Built-File "crashrpt\lib\CrashRpt1402d.lib" "..\lib\CrashRpt1402d.lib"
Copy-Built-File "crashrpt\lib\CrashRpt1402.lib" "..\lib\CrashRpt1402.lib"

if(!(Test-Path "cryptopp\c5\cryptlib.vcxproj"))
{
	Log-Action "Upgrading Crypto++ project..."
	cmd /c "vcupgrade.exe cryptopp\c5\cryptlib.vcproj" 

	Log-Action "Fixing runtime library in Crypto++ project file..."
	(Get-Content "cryptopp\c5\cryptlib.vcxproj") | Foreach-Object {
		$_ -replace '</RuntimeLibrary>', 'DLL</RuntimeLibrary>'
	} | Set-Content "cryptopp\c5\cryptlib.vcxproj"

	Write-Host "Upgrade completed"
}

Log-Action "Removing Crypto++ from SDK..."
Cleanup-File "..\lib\cryptlibd.lib"
Cleanup-File "..\lib\cryptlib.lib"

Log-Action "Cleaning Crypto++ solution..."
Run-MSBuild "cryptopp\c5\cryptlib.vcxproj" "Debug" "/t:Clean /m"
Run-MSBuild "cryptopp\c5\cryptlib.vcxproj" "Release" "/t:Clean /m"

Log-Action "Building Crypto++ in Debug..."
Run-MSBuild "cryptopp\c5\cryptlib.vcxproj" "Debug" "/m"

Log-Action "Bulding Crypto++ in Release..."
Run-MSBuild "cryptopp\c5\cryptlib.vcxproj" "Release" "/m"

Log-Action "Moving built files to SDK..."
Copy-Built-File "cryptopp\c5\Win32\Output\Debug\cryptlib.lib" "..\lib\cryptlibd.lib"
Copy-Built-File "cryptopp\c5\Win32\Output\Release\cryptlib.lib" "..\lib\cryptlib.lib"

Write-Host "All thirdparty libraries successfully built and copied to SDK" -foregroundcolor green -backgroundcolor black
