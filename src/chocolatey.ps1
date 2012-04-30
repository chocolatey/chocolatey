﻿param(
  [string]$command,
  [string]$packageName='',
  [string]$source='',
  [string]$version='',
  [alias("all")][switch] $allVersions = $false,
  [alias("ia","installArgs")][string] $installArguments = '',
  [alias("o","override","overrideArguments","notSilent")]
  [switch] $overrideArgs = $false,
  [switch] $force = $false,
  [alias("pre")][switch] $prerelease = $false,
  [switch] $debug
) 

# chocolatey
# Copyright (c) 2011-Present Rob Reynolds
# Crediting contributions by Chris Ortman, Nekresh, Staxmanade, Chrissie1, AnthonyMastrean
# Big thanks to Keith Dahlby for all the powershell help! 
# Apache License, Version 2.0 - http://www.apache.org/licenses/LICENSE-2.0

## Set the culture to invariant
$currentThread = [System.Threading.Thread]::CurrentThread;
$culture = [System.Globalization.CultureInfo]::InvariantCulture;
$currentThread.CurrentCulture = $culture;
$currentThread.CurrentUICulture = $culture;

#Let's get Chocolatey!
$chocVer = '0.9.8.17-alpha1'
$nugetChocolateyPath = (Split-Path -parent $MyInvocation.MyCommand.Definition)
$nugetPath = (Split-Path -Parent $nugetChocolateyPath)
$nugetExePath = Join-Path $nuGetPath 'bin'
$nugetLibPath = Join-Path $nuGetPath 'lib'
$chocInstallVariableName = "ChocolateyInstall"
$nugetExe = Join-Path $nugetChocolateyPath 'nuget.exe'
$h1 = '====================================================='
$h2 = '-------------------------'

$DebugPreference = "SilentlyContinue"
if ($debug) {$DebugPreference = "Continue";}

# grab functions from files
Resolve-Path $nugetChocolateyPath\functions\*.ps1 | 
    ? { -not ($_.ProviderPath.Contains(".Tests.")) } |
    % { . $_.ProviderPath }

#main entry point
Remove-LastInstallLog

switch -wildcard ($command) 
{
  "install" { Chocolatey-Install $packageName $source $version $installArguments; }
  "installmissing" { Chocolatey-InstallIfMissing $packageName $source $version; }
  "update" { Chocolatey-Update $packageName $source; }
  "list" { Chocolatey-List $packageName $source; }
  "version" { Chocolatey-Version $packageName $source; }
  "webpi" { Chocolatey-WebPI $packageName $installArguments; }
  "gem" { Chocolatey-RubyGem $packageName $version $installArguments; }
  "pack" { Chocolatey-Pack $packageName; }
  "push" { Chocolatey-Push $packageName $source; }
  "help" { Chocolatey-Help; }
  default { Write-Host 'Please run chocolatey /? or chocolatey help'; }
}