$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
$base = Split-Path -parent (Split-Path -Parent $here)
. $common
. "$base\src\helpers\functions\Install-ChocolateyService.ps1"

Describe "Install-ChocolateyService" {
  Context "When no packageName parameter is passed to this function" {
    Mock Write-ChocolateyFailure
	
	Install-ChocolateyService -serviceName "TestWorkingDiectory" -createServiceCommand "TestArguments"	

	It "should return an error" {
	  Assert-MockCalled Write-ChocolateyFailure -parameterFilter { $failureMessage  -eq "Missing PackageName input parameter." }
	}
  }
	
  Context "When no serviceName parameter is passed to this function" {
	Mock Write-ChocolateyFailure
		
	Install-ChocolateyService -packageName "TestTargetPath" -createServiceCommand "TestArguments"
		
	It "should return an error" {
	  Assert-MockCalled Write-ChocolateyFailure -parameterFilter { $failureMessage  -eq "Missing ServiceName input parameter." }
	}
  }

  Context "When no createServiceCommand parameter is passed to this function" {
    Mock Write-ChocolateyFailure
		
	Install-ChocolateyService -packageName "TestTargetPath" -serviceName "TestWorkingDiectory"
		
	It "should return an error" {
	  Assert-MockCalled Write-ChocolateyFailure -parameterFilter { $failureMessage  -eq "Missing CreateServiceCommand input parameter." }
	}
  }
	
  Context "When service does not exist" {
    Mock Write-ChocolateyFailure
		
	Install-ChocolateyService -packageName "helloworld" -serviceName "helloworld"  -createServiceCommand "notepad"
		
	It "should return an error" {
	  Assert-MockCalled Write-ChocolateyFailure -parameterFilter { $failureMessage  -eq "service helloworld does not exist." }
	}
  }	
	
  Context "When createServiceCommand is incorrect" {
    Mock Write-ChocolateyFailure
		
	Install-ChocolateyService -packageName "helloworld" -serviceName "helloworld"  -createServiceCommand "c:\helloworld"
		
	It "should return an error" {
	  Assert-MockCalled Write-ChocolateyFailure -parameterFilter { $failureMessage  -eq "createServiceCommand c:\helloworld is incorrect." }
	}
  }
}