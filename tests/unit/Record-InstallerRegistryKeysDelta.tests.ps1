$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
. $common

$data1 = New-Object PSObject -Property @{Key = "HKEY_LOCAL_MACHINE\Windows\fdsjklfds"; DisplayName = "My Exe 1.01"; SignficantUser = ''; UninstallCommand = """C:\P F\someuninst.exe"" blah stuff"}
$data2 = New-Object PSObject -Property @{Key = "HKEY_CURRENT_USER\fdsjklfds"; DisplayName = "MSITastic 1.01"; SignficantUser = ''; UninstallCommand = "msiexec.exe /i{fsdfds-453543-GHJGHJ}"}
$data2a = New-Object PSObject -Property @{Key = "HKEY_CURRENT_USER\fdsjklfds"; DisplayName = "MSITastic 1.02"; SignficantUser = ''; UninstallCommand = "msiexec.exe /i{fsdfds-453543-GHJGHJ}"}
$data2b = New-Object PSObject -Property @{Key = "HKEY_CURRENT_USER\fdsjklfds"; DisplayName = "MSITastic 1.01"; SignficantUser = ''; UninstallCommand = "msiexec.exe /i{fsdfgdfgfdJGHJ}"}
$data3 = New-Object PSObject -Property @{Key = "HKEY_CURRENT_USER\fdsjklfdsfsfds"; DisplayName = "Blah v2"; SignficantUser = ''; UninstallCommand = "msiexec.exe /i{fsdfgdfgfdJGHJ}"}

$packageName = 'mypackage'
$packageFolder = 'TestDrive:\'
$uninstallKeysFile = join-path "$packageFolder" "$packageName-uninstallkeys.txt"

Describe "When calling Record-InstallerRegistryKeysDelta" {

  Context "When no new registry key appears during the install" {
    $same = @($data1)
    if (Test-Path $uninstallKeysFile) { Remove-Item $uninstallKeysFile }

    Record-InstallerRegistryKeysDelta $packageName $packageFolder $same $same

    It "should result in no uninstallkeys file" {
      Test-Path $uninstallKeysFile | Should Be $false
    }
  }

  Context "When a new registry key appears during the install" {
    $before = @($data1)
    $after = @($data1, $data2)

    Record-InstallerRegistryKeysDelta $packageName $packageFolder $before $after

    It "should be noted for later" {
      # In powershell v2, need to force result of ConvertFrom-Csv to an array
      $uninstallKeys = @(Get-Content $uninstallKeysFile -Encoding UTF8 | ConvertFrom-Csv)
      $uninstallKeys.Length | Should Be 1
      $uninstallKeys[0].DisplayName | Should Be "MSITastic 1.01"
    }
  }

  Context "When a existing registry key changes DisplayName during the install" {
    $before = @($data1, $data2)
    $after = @($data1, $data2a)

    Record-InstallerRegistryKeysDelta $packageName $packageFolder $before $after

    It "should be noted for later" {
      $uninstallKeys = @(Get-Content $uninstallKeysFile -Encoding UTF8 | ConvertFrom-Csv)
      $uninstallKeys.Length | Should Be 1
      $uninstallKeys[0].DisplayName | Should Be "MSITastic 1.02"
    }
  }

  Context "When a existing registry key changes UninstallCommand during the install" {
    $before = @($data1, $data2)
    $after = @($data1, $data2b)

    Record-InstallerRegistryKeysDelta $packageName $packageFolder $before $after

    It "should be noted for later" {
      $uninstallKeys = @(Get-Content $uninstallKeysFile -Encoding UTF8 | ConvertFrom-Csv)
      $uninstallKeys.Length | Should Be 1
      $uninstallKeys[0].UninstallCommand | Should Be "msiexec.exe /i{fsdfgdfgfdJGHJ}"
    }
  }

  Context "When two keys appear" {
    $before = @($data1)
    $after = @($data1, $data2, $data3)

    Record-InstallerRegistryKeysDelta $packageName $packageFolder $before $after

    It "they both are noted for later" {
      $uninstallKeys = @(Get-Content $uninstallKeysFile -Encoding UTF8 | ConvertFrom-Csv)
      $uninstallKeys.Length | Should Be 2
      $uninstallKeys[0].DisplayName | Should Be "MSITastic 1.01"
      $uninstallKeys[1].DisplayName | Should Be "Blah v2"
    }
  }
}
