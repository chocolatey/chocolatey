$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
$base = Split-Path -parent (Split-Path -Parent $here)
. $common
$helperFunctionBase = "$base\src\helpers\functions"
. "$helperFunctionBase\Install-ChocolateyZipPackage.ps1"
. "$helperFunctionBase\Delete-ChocolateyDirectory.ps1"

$packageName = "test"
$testDirectory = "C:\installChocolateyArchivePackage"
$testFileDirectory = "$testDirectory\test"
$testZip = "$testFileDirectory.zip"
$testTar = "$testFileDirectory.tar"
$testTarGz = "$testTar.gz"
$testZipDirectory = "$testDirectory\zip"
$testTarGzDirectory = "$testDirectory\tarGz"

$env:chocolateyPackageFolder = "c:\Chocolatey\lib"
$env:ChocolateyInstall = "c:\Chocolatey"

if (!(Test-Path $testFileDirectory)) {
  new-item $testFileDirectory -itemtype directory
}

Invoke-Expression -Command:"$7zip a $testFileDirectory.zip $testFileDirectory"
Invoke-Expression -Command:"$7zip a $testFileDirectory.tar $testFileDirectory"
Invoke-Expression -Command:"$7zip a $testFileDirectory.tar.gz $testFileDirectory.tar"

Describe "Install-ChocolateyArchivePackage" {
  Context "When no packageName parameter is passed to this function" {
    Mock Write-ChocolateyFailure

	Install-ChocolateyArchivePackage -url "$testZip" -unzipLocation "$testDirectory"
	
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

	Install-ChocolateyZipPackage -packageName "$packageName" -url "$testZip"
	
	It "should return an error" {
      Assert-MockCalled Write-ChocolateyFailure -parameterFilter { $failureMessage  -eq "Missing UnzipLocation input parameter." }
    }
  }  

  Context "When required parameters are passed and Zip needs to be installed it should succeed" {	
	Install-ChocolateyZipPackage -packageName "$packageName" -url "$testZip" -unzipLocation "$testZipDirectory"
		
	It "should extract the ZipPackage" {
      Test-Path $testZipDirectory\$packageName | should Be $true
    }
  }
  
  Context "When required parameters are passed and Tar.gz needs to be installed it should succeed" {	
	Install-ChocolateyZipPackage -packageName "$packageName" -url "$testTarGz" -unzipLocation "$testTarGzDirectory"
		
	It "should extract the TarGzPackage" {
      Test-Path $testTarGzDirectory\$packageName | should Be $true
    }
  }
  Delete-ChocolateyDirectory "$testDirectory"
}