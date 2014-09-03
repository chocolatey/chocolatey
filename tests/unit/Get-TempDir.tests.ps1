$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
. $common

Setup -File 'userprofile\_crapworkaround.txt'
Describe "Get-TempDir" {
  Context "when retrieving the temp dir without a configured value" {
    $oldProfile = $env:USERPROFILE
    $env:USERPROFILE = Join-Path 'TestDrive:' 'userProfile'
    Setup -File 'chocolatey\chocolateyInstall\chocolatey.config' @"
<?xml version="1.0"?>
<chocolatey />
"@
    $result = Get-TempDir
    $env:USERPROFILE = $oldProfile

    It "should return the default temp directory %TEMP%" {
      $result  | should Be $env:TEMP
    }
  }

  Context "when retrieving the temp dir with a configured value" {
      $oldProfile = $env:USERPROFILE
      $env:USERPROFILE = Join-Path 'TestDrive:' 'userProfile'
      Setup -File 'chocolatey\chocolateyInstall\chocolatey.config' @"
<?xml version="1.0"?>
<chocolatey>
  <tempDir>%USERPROFILE%\TEMP</tempDir>
</chocolatey>
"@
    $result = Get-TempDir
    $expectedResult = Join-Path $env:USERPROFILE 'TEMP'
    $env:USERPROFILE = $oldProfile

    It "should return the configured temp directory %USERPROFILE%\TEMP" {
      $result  | should Be $expectedResult
    }
  }
}
