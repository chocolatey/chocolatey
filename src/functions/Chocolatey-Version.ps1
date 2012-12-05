﻿function Chocolatey-Version {
param(
  [string] $packageName='',
  [string] $source=''
)

  if ($packageName -eq '') {$packageName = 'chocolatey';}
  Write-Debug "Running 'Chocolatey-Version' for $packageName with source:`'$source`'.";
  
  $packages = $packageName
  if ($packageName -eq 'all') {
    Write-Debug "Reading all packages in $nugetLibPath"
    $packageFolders = Get-ChildItem $nugetLibPath | sort name
    $packages = $packageFolders -replace "(\.\d.*)+"|gu 
  }
  
  $srcArgs = Get-SourceArguments $source
  
  Write-Debug "based on: `'$srcArgs`' feed"
  
  $logFile = Join-Path $nugetChocolateyPath 'list.log'
  $packageArgs = "list $srcArgs"
  if ($prerelease -eq $true) {
      $packageArgs = $packageArgs + " -Prerelease";
  }

  if (!$localOnly) {
    Start-Process $nugetExe -ArgumentList $packageArgs -NoNewWindow -Wait -RedirectStandardOutput $logFile
    Start-Sleep 1 #let it finish writing to the config file
  }

  foreach ($package in $packages) {

    $versionFound = $chocVer
    
    if ($packageName -ne 'chocolatey') {
      $versionFound = 'no version'
      $packageFolderVersion = Get-LatestPackageVersion(Get-PackageFolderVersions($package))

      if ($packageFolderVersion -notlike '') { 
        #Write-Host $packageFolder
        $versionFound = $packageFolderVersion
      }
    }
    
    if (!$localOnly) {
      $versionLatest = Get-Content $logFile | ?{$_ -match "^$package\s+\d+"} | sort $_ -Descending | select -First 1 
      $versionLatest = $versionLatest -replace "$package ", "";
      #todo - make this compare prerelease information as well
      $versionLatestCompare = Get-LongPackageVersion $versionLatest
      
      $versionFoundCompare = ''
      if ($versionFound -ne 'no version') {
          $versionFoundCompare = Get-LongPackageVersion $versionFound
      }    
      
      $verMessage = "A more recent version is available"
      if ($versionLatest -eq $versionFound) { 
          $verMessage = "Latest version installed"
      }
      if ($versionLatestCompare -lt $versionFoundCompare) {
          $verMessage = "Your version is newer than the most recent. You must be smarter than the average bear..."
      }
      if ($versionLatest -eq '') {
          $verMessage = "$package does not appear to be on the source(s) specified: "
      }
      
      $versions = @{name=$package; latest = $versionLatest; found = $versionFound; latestCompare = $versionLatestCompare; foundCompare = $versionFoundCompare; verMessage = $verMessage}
      $versionsObj = New-Object –typename PSObject -Property $versions
      $versionsObj
    }
    
    else {
      $versions = @{name=$package; found = $versionFound}
      $versionsObj = New-Object –typename PSObject -Property $versions
      $versionsObj
    }
  }
}