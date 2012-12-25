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

if((!(VS-Env VS110COMNTOOL "Visual Studio 2012")) -and (!(VS-Env VS100COMNTOOLS "Visual Studio 2010")))
{
	$Host.UI.WriteErrorLine("Failed to determine Visual Studio tools path. Make sure you have VS2010 or VS2012 installed.")
	Exit 
}

