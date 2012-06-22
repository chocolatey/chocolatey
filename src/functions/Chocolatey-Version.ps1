﻿function Chocolatey-Version {
param(
  [string] $packageName='',
  [string[]] $source=''
)

  if ($packageName -eq '') {$packageName = 'chocolatey';}
  Write-Debug "Running 'Chocolatey-Version' for $packageName with source:`'$source`'.";
  
  $packages = $packageName
  if ($packageName -eq 'all') {
    Write-Debug "Updating all packages in $nugetLibPath"
    $packageFolders = Get-ChildItem $nugetLibPath | sort name
    $packages = $packageFolders -replace "(\.\d{1,})+"|gu 
  }
  
  $srcArgs = Get-SourceArguments $source
  
  foreach ($package in $packages) {
    $packageArgs = "list ""$package"" $srcArgs"
    if ($prerelease -eq $true) {
      $packageArgs = $packageArgs + " -Prerelease";
    }
    #write-host "TEMP: Args - $packageArgs"

    $logFile = Join-Path $nugetChocolateyPath 'list.log'
    Start-Process $nugetExe -ArgumentList $packageArgs -NoNewWindow -Wait -RedirectStandardOutput $logFile
    Start-Sleep 1 #let it finish writing to the config file

    $versionLatest = Get-Content $logFile | ?{$_ -match "^$package\s+\d+"} | sort $_ -Descending | select -First 1 
    $versionLatest = $versionLatest -replace "$package ", "";
    #todo - make this compare prerelease information as well
    $versionLatestCompare = Get-LongPackageVersion $versionLatest

    $versionFound = $chocVer
    if ($packageName -ne 'chocolatey') {
      $versionFound = 'no version'
      $packageFolderVersion = Get-LatestPackageVersion(Get-PackageFolderVersions($package))

      if ($packageFolderVersion -notlike '') { 
        #Write-Host $packageFolder
        $versionFound = $packageFolderVersion
      }
    }
    
    $versionFoundCompare = ''
    if ($versionFound -ne 'no version') {
      $versionFoundCompare = Get-LongPackageVersion $versionFound
    }    
  
    $verMessage = "The most recent version of $package available from `'$srcArgs`' (if value is empty, using sources in nuget.config file) is $versionLatest. On your machine you have $versionFound installed."
    if ($versionLatest -eq $versionFound) { 
      $verMessage = "You have the latest version of $package ($versionLatest) based on: `'$srcArgs`' (if value is empty, using sources in nuget.config file)."
    }
    if ($versionLatestCompare -lt $versionFoundCompare) {
      $verMessage = "$verMessage You must be smarter than the average bear..."
    }
    if ($versionLatest -eq '') {
      $verMessage = "$package does not appear to be on the source(s) specified: `'$srcArgs`' (if value is empty, using sources in nuget.config file). You have $versionFound installed. Interesting..."
    }
    Write-Host $verMessage
  }
  
	$versions = @{name=$package; latest = $versionLatest; found = $versionFound; latestCompare = $versionLatestCompare; foundCompare = $versionFoundCompare; }
	$versionsObj = New-Object –typename PSObject -Property $versions
	return $versionsObj
}
