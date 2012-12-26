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

function VS-Env($envvar, $name)
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
	Write-Host "Environment variables loaded successfully" -foregroundcolor green -backgroundcolor black
	
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

function Move-Built-File($path, $to)
{
	try
	{
		Move-Item $path $to
		Write-Host $path "moved"
	}
	catch [Exception]
	{
		$Host.UI.WriteErrorLine("$path not found. This indicates that the build script is out of date and needs to be updated.")
		Exit
	}
}

function Run-MSBuild($sln, $params)
{
	$cmd = "MSBuild $sln $params"
	Invoke-Expression $cmd
	
	if($LASTEXITCODE -ne 0)
	{
		$Host.UI.WriteErrorLine("`nMSBuild failed on $sln (Cmd = $cmd).")
		Exit
	}
}

Log-Action "Setting Visual Studio environment..."
if((!(VS-Env VS110COMNTOOLS "Visual Studio 2012")) -and (!(VS-Env VS100COMNTOOLS "Visual Studio 2010")))
{
	$Host.UI.WriteErrorLine("Failed to determine Visual Studio tools path. Make sure you have VS2010 or VS2012 installed.")
	Exit 
}

Log-Action "Removing Crashrpt from SDK..."
Cleanup-File "..\bin\Debug\CrashRpt1400d.dll"
Cleanup-File "..\bin\Release\CrashRpt1400.dll"
Cleanup-File "..\bin\Debug\crashrpt_lang.ini"
Cleanup-File "..\bin\Release\crashrpt_lang.ini"
Cleanup-File "..\bin\Debug\CrashSender1400d.exe"
Cleanup-File "..\bin\Release\CrashSender1400.exe"
Cleanup-File "..\lib\CrashRpt1400.lib"
Cleanup-File "..\lib\CrashRpt1400d.lib"

Log-Action "Cleaning CrashRpt solution..."
Run-MSBuild "crashrpt\CrashRpt_vs2010.sln" "/p:Configuration=Debug /t:Clean /m"
Run-MSBuild "crashrpt\CrashRpt_vs2010.sln" "/p:Configuration=Release /t:Clean /m"

Log-Action "Building CrashRpt in Debug..."
Run-MSBuild "crashrpt\CrashRpt_vs2010.sln" "/p:Configuration=Debug /m"

Log-Action "Building CrashRpt in Release..." 
Run-MSBuild "crashrpt\CrashRpt_vs2010.sln" "/p:Configuration=Release /m"

Log-Action "Moving built files to SDK..."
Move-Built-File "crashrpt\bin\CrashRpt1400d.dll" "..\bin\Debug\CrashRpt1400d.dll"
Move-Built-File "crashrpt\bin\CrashRpt1400.dll" "..\bin\Release\CrashRpt1400.dll"

Move-Built-File "crashrpt\bin\crashrpt_lang.ini" "..\bin\Debug\crashrpt_lang.ini"
Move-Built-File "crashrpt\bin\crashrpt_lang.ini" "..\bin\Release\crashrpt_lang.ini"

Move-Built-File "crashrpt\bin\CrashSender1400d.exe" "..\bin\Debug\CrashSender1400d.exe"
Move-Built-File "crashrpt\bin\CrashSender1400.exe" "..\bin\Release\CrashSender1400.exe"

Move-Built-File "crashrpt\lib\CrashRpt1400d.lib" "..\lib\CrashRpt1400d.lib"
Move-Built-File "crashrpt\lib\CrashRpt1400.lib" "..\lib\CrashRpt1400.lib"
