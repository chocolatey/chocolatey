$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
$base = Split-Path -parent (Split-Path -Parent $here)

. $common

$data1 = New-Object PSObject -Property @{Key = "HKEY_LOCAL_MACHINE\Windows\stuff\fdsjklfds"; DisplayName = "My Exe 1.01"; SignficantUser = ''; UninstallCommand = """C:\Prog Files\someuninst.exe"" blah stuff"}
$data2 = New-Object PSObject -Property @{Key = "HKEY_CURRENT_USER\fdsjklfds"; DisplayName = "MSITastic 1.01"; SignficantUser = ''; UninstallCommand = "msiexec.exe /i{fsdfds-453543-GHJGHJ}"}
$data3 = New-Object PSObject -Property @{Key = "HKEY_CURRENT_USER\Windows\yada"; DisplayName = "dsadsa 1.01"; SignficantUser = '{54534}'; UninstallCommand = "msiexec.exe /x {fsd-453gfsdgfsd543-GHJGHJ}"}
$packageFolder = 'TestDrive:\'
$packageName = 'mypackage'
$uninstallKeysFile = join-path "$packageFolder" "$packageName-uninstallkeys.txt"


Describe "Chocolatey-AutoUninstall" {
  Context "When uninstall data file is missing" {
    Mock Start-ChocolateyProcessAsAdmin
    if (Test-Path $uninstallKeysFile) { Remove-Item $uninstallKeysFile }

    $aborted = $false
    try {
      Chocolatey-AutoUninstall $packageFolder $packageName
    } catch {
      $aborted = $true
    }
    It "should abort" {
      Assert-MockCalled Start-ChocolateyProcessAsAdmin -Exactly 0
      $aborted | Should Be $true
    }
  }

  Context "When uninstall data file is empty" {
    Mock Start-ChocolateyProcessAsAdmin
    Setup -File "$packageName-uninstallkeys.txt" ""

    $aborted = $false
    try {
      Chocolatey-AutoUninstall $packageFolder $packageName
    } catch {
      $aborted = $true
    }
    It "should abort" {
      Assert-MockCalled Start-ChocolateyProcessAsAdmin -Exactly 0
      $aborted | Should Be $true
    }
  }

  Context "When uninstall data file contains an invalid key" {
    Mock Start-ChocolateyProcessAsAdmin
    Setup -File "$packageName-uninstallkeys.txt" "NotARegKey"

    $aborted = $false
    try {
      Chocolatey-AutoUninstall $packageFolder $packageName
    } catch {
      $aborted = $true
    }
    It "should abort" {
      Assert-MockCalled Start-ChocolateyProcessAsAdmin -Exactly 0
      $aborted | Should Be $true
    }
  }

  Context "When uninstall data indicates another user ran a per-user install" {
    Mock Start-ChocolateyProcessAsAdmin
    Mock Get-UninstallerRegistryKeys { @($data1, $data2) }
    @($data3) | Export-CSV $uninstallKeysFile -Encoding UTF8 -Force

    $aborted = $false
    try {
      Chocolatey-AutoUninstall $packageFolder $packageName
    } catch {
      $aborted = $true
    }
    It "should abort" {
      Assert-MockCalled Get-UninstallerRegistryKeys -Exactly 0
      Assert-MockCalled Start-ChocolateyProcessAsAdmin -Exactly 0
      $aborted | Should Be $true
    }
  }

  Context "When uninstall data indicates this user ran a per-user install" {
    Mock Start-ChocolateyProcessAsAdmin
    $dataMe = $data3
    $dataMe.SignficantUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().User
    Mock Get-UninstallerRegistryKeys { @($data1, $data2, $dataMe) }
    @($dataMe) | Export-CSV $uninstallKeysFile -Encoding UTF8 -Force

    Chocolatey-AutoUninstall $packageFolder $packageName
    It "should uninstall properly" {
      Assert-MockCalled Get-UninstallerRegistryKeys -Exactly 1
      Assert-MockCalled Start-ChocolateyProcessAsAdmin -Exactly 1
    }
  }

  Context "When uninstall data file contains an valid but no longer present key" {
    Mock Start-ChocolateyProcessAsAdmin
    Mock Get-UninstallerRegistryKeys { @($data1, $data3) }
    @($data2) | Export-CSV $uninstallKeysFile -Encoding UTF8 -Force

    Chocolatey-AutoUninstall $packageFolder $packageName
    It "should silently ignore the key" {
      Assert-MockCalled Get-UninstallerRegistryKeys -Exactly 1
      Assert-MockCalled Start-ChocolateyProcessAsAdmin -Exactly 0
    }
  }

  Context "When uninstall exec is a quoted exe" {
    Mock Start-ChocolateyProcessAsAdmin {} -Verifiable -ParameterFilter { $statements -eq "blah stuff" -and $exeToRun -eq "C:\Prog Files\someuninst.exe" }
    Mock Get-UninstallerRegistryKeys { @($data1, $data2, $data3) }
    @($data1) | Export-CSV $uninstallKeysFile -Encoding UTF8 -Force

    Chocolatey-AutoUninstall $packageFolder $packageName
    It "should run it as given" {
      Assert-VerifiableMocks
      Assert-MockCalled Get-UninstallerRegistryKeys -Exactly 1
      Assert-MockCalled Start-ChocolateyProcessAsAdmin -Exactly 1
    }
  }

  Context "When uninstall exec is a single msiexec.exe call" {
    Mock Start-ChocolateyProcessAsAdmin {} -Verifiable -ParameterFilter { $statements -eq "/x{fsdfds-453543-GHJGHJ} /quiet" -and $exeToRun -eq "msiexec.exe" }
    Mock Get-UninstallerRegistryKeys { @($data1, $data2, $data3) }
    @($data2) | Export-CSV $uninstallKeysFile -Encoding UTF8 -Force

    Chocolatey-AutoUninstall $packageFolder $packageName
    It "should run it quietly" {
      Assert-MockCalled Get-UninstallerRegistryKeys -Exactly 1
      Assert-MockCalled Start-ChocolateyProcessAsAdmin -Exactly 1
      Assert-VerifiableMocks
    }
  }

  Context "When uninstall exec is in two parts" {
    Mock Start-ChocolateyProcessAsAdmin
    Mock Get-UninstallerRegistryKeys { @($data1, $data2, $data3) }
    @($data1, $data2) | Export-CSV $uninstallKeysFile -Encoding UTF8 -Force

    Chocolatey-AutoUninstall $packageFolder $packageName
    It "should run it as given" {
      Assert-MockCalled Start-ChocolateyProcessAsAdmin -Exactly 2
    }
  }
}
