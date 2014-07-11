$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
$base = Split-Path -parent (Split-Path -Parent $here)
. $common
. "$base\src\helpers\functions\Install-ChocolateyZipPackage.ps1"
. "$base\tests\unit\Delete-ChocolateyTestDirectory.ps1"

$packageName = "test"
$testDirectory = "C:\installChocolateyArchivePackage"
$url = "http://apache.mirror1.spango.com/tomcat/tomcat-8/v8.0.9/bin/apache-tomcat-8.0.9-windows-x64"
#$urlTarGz = "$url.tar.gz"
$urlZip = "${url}.zip"

$env:chocolateyPackageFolder = "c:\Chocolatey\lib"
$env:ChocolateyInstall = "c:\Chocolatey"

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

	Install-ChocolateyZipPackage -packageName "$packageName" -url "$url"
	
	It "should return an error" {
      Assert-MockCalled Write-ChocolateyFailure -parameterFilter { $failureMessage  -eq "Missing UnzipLocation input parameter." }
    }
  }  

  Context "When required parameters are passed and Zip needs to be installed it should succeed" {	
	Install-ChocolateyZipPackage -packageName "$packageName" -url "$urlZip" -unzipLocation "$testDirectory"
		
	It "should extract the ZipPackage" {
      
    }
  }
  Delete-ChocolateyTestDirectory "$testDirectory"
}