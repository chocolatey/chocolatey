$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
$base = Split-Path -parent (Split-Path -Parent $here)
. $common
. "$base\src\helpers\functions\Install-ChocolateyArchivePackage.ps1"
. "$base\tests\unit\Delete-ChocolateyTestDirectory.ps1"

$packageName = "test"
$testDirectory = "C:\installChocolateyArchivePackage"
$url = "https://github.com/030/chocolatey-1/blob/c82307f02755a529f60fe19a9fbc3fbee076bf05/tests/Install-ChocolateyArchivePackageFiles/Install-ChocolateyArchivePackageFiles.tar.gz"

Describe "Install-ChocolateyArchivePackage" {
  Context "When no packageName parameter is passed to this function" {
    Mock Write-ChocolateyFailure

	Install-ChocolateyArchivePackage -url "$url" -unzipLocation "$testDirectory"
	
	It "should return an error" {
      Assert-MockCalled Write-ChocolateyFailure -parameterFilter { $failureMessage  -eq "Missing PackageName input parameter." }
    }
  }

  Context "When no url parameter is passed to this function" {
    Mock Write-ChocolateyFailure

	Install-ChocolateyArchivePackage -packageName "$packageName" -unzipLocation "$testDirectory"
	
	It "should return an error" {
      Assert-MockCalled Write-ChocolateyFailure -parameterFilter { $failureMessage  -eq "Missing Url input parameter." }
    }
  }
  
  Context "When no unzipLocation parameter is passed to this function" {
    Mock Write-ChocolateyFailure

	Install-ChocolateyArchivePackage -packageName "$packageName" -url "$url"
	
	It "should return an error" {
      Assert-MockCalled Write-ChocolateyFailure -parameterFilter { $failureMessage  -eq "Missing UnzipLocation input parameter." }
    }
  }
}