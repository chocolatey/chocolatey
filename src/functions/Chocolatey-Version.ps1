function Chocolatey-Version {
param(
  [string] $packageName='',
  [string] $version='',
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

  if ($version -eq 'all') {
    $packageFolders=Get-PackageFoldersForPackage $packageName
    $packageversions=$packageFolders -replace "$packageName\."
  }
  
  $srcArgs = Get-SourceArguments $source
  
  Write-Debug "based on: `'$srcArgs`' feed"
  
  $versionsObj = New-Object –typename PSObject
  foreach ($package in $packages) {
    $packageArgs = "list ""$package"" $srcArgs -NonInteractive"
    if ($prerelease -eq $true) {
      $packageArgs = $packageArgs + " -Prerelease";
    }
    #write-host "TEMP: Args - $packageArgs"

    $logFile = Join-Path $nugetChocolateyPath 'list.log'

    $versionFound = $chocVer
    
    if ($packageName -ne 'chocolatey') {
      $versionFound = 'no version'
      
      if ($version -eq 'all') {
      $packagefolderversion = $packageversions
      }
      else {
        $packageFolderVersion = Get-LatestPackageVersion(Get-PackageFolderVersions($package))
      }


      if ($packageFolderVersion -notlike '') { 
        #Write-Host $packageFolder
        $versionFound = $packageFolderVersion
      }
    }
    
    if (!$localOnly) {
      Write-Debug "Calling `'$nugetExe`' $packageArgs"
      Start-Process $nugetExe -ArgumentList $packageArgs -NoNewWindow -Wait -RedirectStandardOutput $logFile
      Start-Sleep 1 #let it finish writing to the config file
      
      $nugetOutput = Get-Content $logFile
      foreach ($line in $nugetOutput) {
        if ($line -ne $null) {Write-Debug $line;}
      }
      
      $versionLatest = $nugetOutput | ?{$_ -match "^$package\s+\d+"} | sort $_ -Descending | select -First 1 
      $versionLatest = $versionLatest -replace "$package ", "";
      #todo - make this compare prerelease information as well
      $versionLatestCompare = Get-LongPackageVersion $versionLatest
      
      $versionFoundCompare = ''
      if ($versionFound -ne 'no version') {
          $versionFoundCompare = Get-LongPackageVersion $versionFound
      }    
      
      $verMessage = "A more recent version is available"
      if ($versionLatestCompare -eq $versionFoundCompare) { 
          $verMessage = "Latest version installed"
      }
      if ($versionLatestCompare -lt $versionFoundCompare) {
          $verMessage = "Your version is newer than the most recent. You must be smarter than the average bear..."
      }
      if ($versionLatest -eq '') {
          $verMessage = "$package does not appear to be on the source(s) specified: "
      }
      
      foreach ($versions in $versionfound) {
        $versions = @{name=$package; latest = $versionLatest; found = $versions; latestCompare = $versionLatestCompare; foundCompare = $versionFoundCompare; verMessage = $verMessage}
        $versionsObj = New-Object –typename PSObject -Property $versions
        $versionsObj
      }
    }
    
    else {
      foreach ($versions in $versionfound) {
        $versions = @{name=$package; found = $versions}
        $versionsObj = New-Object –typename PSObject -Property $versions
        $versionsObj
      }
    }
  }
}