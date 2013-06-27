function New-BinFile {
<#
.SYNOPSIS 
    Generate a wrapper batch and bash shell file for an executable
.PARAMETER name
    The basename of the batch and bash shell files
.PARAMETER path
    The full path of the executable to set the batch and bash shell files for
.PARAMETER outPath
    The folder to create the wrapper batch and bash shell files in
.PARAMETER useStart
    Set to true to have the wrapper batch and bash shell files execute $path asynchronously
#>
[CmdletBinding()]
param(
  [string] $name, 
  [string] $path,
  [string] $outPath,
  [switch] $useStart
)
  Write-Debug "Running 'Generate-BinFile' for $name with path:`'$path`'";

  $packageBatchFileName = Join-Path $outPath "$name.bat"
  $packageBashFileName = Join-Path $outPath "$name"
  $path = $path.ToLower().Replace($outPath.ToLower(), "%DIR%..\").Replace("\\","\")
  $pathBash = $path.Replace("%DIR%..\","`$DIR/../").Replace("\","/")
  Write-Host "Adding $packageBatchFileName and pointing to `'$path`'." -ForegroundColor $Note
  Write-Host "Adding $packageBashFileName and pointing to `'$path`'." -ForegroundColor $Note
  if ($useStart) {
    Write-Host "Setting up $name as a non-command line application."  -ForegroundColor $Note
"@echo off
SET DIR=%~dp0%
start """" ""$path"" %*" | Out-File $packageBatchFileName -encoding ASCII    

"#!/bin/sh
DIR=`${0%/*}
""$pathBash"" ""`$*"" &" | Out-File $packageBashFileName -encoding ASCII
 
  } else {
"@echo off
SET DIR=%~dp0%
""$path"" %*" | Out-File $packageBatchFileName -encoding ASCII
  
"#!/bin/sh
DIR=`${0%/*}
""$pathBash"" ""`$*""" | Out-File $packageBashFileName -encoding ASCII
  }
}