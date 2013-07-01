function Safe-Resolve-Path($filename)
{
    $filename = Resolve-Path $filename -ErrorAction SilentlyContinue -ErrorVariable _frperror
    if(!$filename)
    {
        return $_frperror[0].TargetObject
    }
    return $filename
}

function Get-SHA256($filename)
{
    $crypto = [System.Security.Cryptography.SHA256]::Create()
    $fs = [System.IO.File]::OpenRead($filename)
    $hash = $crypto.ComputeHash($fs)
    
    return [System.BitConverter]::ToString($hash) -replace "-", ""
}

# Check we've got the solution dir as an arg
if($args.Length -ne 1)
{
    Write-Host "[PREBUILDERR] This script should be run only during the build process"
    exit 1
}

$solutionDir = $args[0]

$tempOut = $solutionDir + "..\src\generated\"
if(!(Test-Path $tempOut))
{
    New-Item $tempOut -ItemType Directory | Out-Null
}

$outputDir = Safe-Resolve-Path($tempOut)
$luaBaseDir = Safe-Resolve-Path($solutionDir + "..\lua\")
$luaIncludesDir = Safe-Resolve-Path($solutionDir + "..\lua\includes\")

Write-Host "[Prebuild] Solution Dir: $solutionDir"
Write-Host "[Prebuild] Lua Dir: $luaBaseDir"
Write-Host "[Prebuild] Lua Includes Dir: $luaIncludesDir"
Write-Host "[Prebuild] Output Dir: $outputDir"

if(!(Test-Path $luaIncludesDir))
{
    Write-Host "[PREBUILDERR] Lua includes directory not found"
    exit 1
}

Write-Host "[Prebuild] Creating LuaHashes.h"

$hashHeader = [System.IO.StreamWriter] ($outputDir.Path + "LuaHashes.h")
$hashHeader.WriteLine("namespace LuaHashes
{");

$luaFiles = Get-ChildItem $luaIncludesDir -Include *.lua -Recurse
$numFiles = $luaFiles.Length
$hashHeader.WriteLine("`tint Count = $numFiles;")
$hashHeader.WriteLine("`tFileHash HashList[] = {")

foreach($file in $luaFiles)
{
    $relative = $file.FullName -replace [Regex]::Escape($luaBaseDir), ""
    $relative = $relative -replace "\\", "\\"

    $hash = Get-SHA256 $file.FullName
    $hashHeader.WriteLine("`t`t{ L""$relative"", ""$hash"" },")
}

$hashHeader.WriteLine("`t};")
$hashHeader.WriteLine("}")
$hashHeader.close()

Write-Host "[Prebuild] $numFiles entries added to LuaHashes.h"

# Setup Git path - this uses the GitHub for Windows path
. (Resolve-Path "$env:LOCALAPPDATA\GitHub\shell.ps1")

$gitTag = git describe --always --tag
$gitBranch = git rev-parse --abbrev-ref HEAD

# Check if there are uncommitted changes
git diff-files --quiet
$dirty = ""
if($LastExitCode -ne 0)
{
    $dirty = " DIRTY"
}

$version = $gitBranch + "@" + $gitTag + $dirty

$versionHeader = [System.IO.StreamWriter] ($outputDir.Path + "SDKVersion.h")
$versionHeader.WriteLine("#include <string>

namespace BL2SDK
{
    const std::string Version = ""$version"";
    const std::wstring VersionW = L""$version"";
}")

$versionHeader.close()

Write-Host "[Prebuild] Wrote version as: $version"
Write-Host "[Prebuild] Completed successfully"
