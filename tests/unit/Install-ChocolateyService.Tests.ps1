$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
$base = Split-Path -parent (Split-Path -Parent $here)
$baseFunctions = "$base\src\helpers\functions"
. $common
. "$baseFunctions\Install-ChocolateyService.ps1"
. "$baseFunctions\Get-ServiceExistence.ps1"
. "$baseFunctions\Get-ServiceStatus.ps1"
. "$base\tests\unit\Install-ChocolateyServiceCorrectParameters.Tests.ps1"

$availablePort = "99999"
$unavailablePort = "135"
$correctServiceName = "installServiceTest"
$unavailableServiceName = "unavailableServiceName"
$testDirectory = "C:\installChocolateyServiceTest"

Describe "Install-ChocolateyService" {
  Context "When provided parameters are correct the service should be created and started" {	
	Install-ChocolateyServiceCorrectParameters.Tests -testDirectory "$testDirectory"
		
	It "service creation should succeed" {
      Get-ServiceExistence -serviceName "$correctServiceName" | should Be $true
    }

	It "service start should succeed" {
      Get-ServiceStatus -serviceName "$correctServiceName" -eq "running" | should Be $true
    }
  }

  Context "When provided parameters are correct and service exist it should be removed, subsequently created and started" {	
	Install-ChocolateyServiceCorrectParameters.Tests -testDirectory "$testDirectory"

	It "service creation should succeed after deletion of previous service" {
      Get-ServiceExistence -serviceName "$correctServiceName" | should Be $true
    }

	It "service start should succeed after deletion of previous service" {
      Get-ServiceStatus -serviceName "$correctServiceName" -eq "running" | should Be $true
    }
  }  
 
  Context "When availablePort parameter is passed to this function and it is in LISTENING state and NOT available" {
    Mock Write-ChocolateyFailure

	Install-ChocolateyServiceCorrectParameters.Tests -testDirectory "$testDirectory" -availablePort "$unavailablePort"
	
	It "should return an error" {
      Assert-MockCalled Write-ChocolateyFailure -parameterFilter { $failureMessage  -eq "$unavailablePort is in LISTENING state and not available." 
	  Write-Host $failureMessage
	  }
    }
  } 
  
  Context "When no packageName parameter is passed to this function" {
    Mock Write-ChocolateyFailure
	
	Install-ChocolateyService -serviceName "$unavailableServiceName" -createServiceCommand "$unavailableServiceName"

	It "should return an error" {
	  Assert-MockCalled Write-ChocolateyFailure -parameterFilter { $failureMessage  -eq "Missing PackageName input parameter." }
	}
  }
	
  Context "When no serviceName parameter is passed to this function" {
	Mock Write-ChocolateyFailure
		
	Install-ChocolateyService -packageName "$unavailableServiceName" -createServiceCommand "$unavailableServiceName"
		
	It "should return an error" {
	  Assert-MockCalled Write-ChocolateyFailure -parameterFilter { $failureMessage  -eq "Missing ServiceName input parameter." }
	}
  }

  Context "When no createServiceCommand parameter is passed to this function" {
    Mock Write-ChocolateyFailure
		
	Install-ChocolateyService -packageName "$unavailableServiceName" -serviceName "$unavailableServiceName"
		
	It "should return an error" {
	  Assert-MockCalled Write-ChocolateyFailure -parameterFilter { $failureMessage  -eq "Missing CreateServiceCommand input parameter." }
	}
  }
	
  Context "When service does not exist" {
    Mock Write-ChocolateyFailure
	
	Install-ChocolateyServiceCorrectParameters.Tests -testDirectory "$testDirectory" -serviceName "$unavailableServiceName"

	It "should return an error" {
	  Assert-MockCalled Write-ChocolateyFailure -parameterFilter { $failureMessage  -eq "service unavailableServiceName does not exist." }
	}
  }	

  Context "When createServiceCommand is incorrect" {
    Mock Write-ChocolateyFailure
	
	Install-ChocolateyServiceCorrectParameters.Tests -testDirectory "$testDirectory" -createServiceCommand "$unavailableServiceName"
		
	It "should return an error" {
	  Assert-MockCalled Write-ChocolateyFailure -parameterFilter { $failureMessage  -eq "The createServiceCommand is incorrect: 'The term 'unavailableServiceName' is not recognized as the name of a cmdlet, function, script file, or operable program. Check the spelling of the name, or if a path was included, verify that the path is correct and try again.'." }
	}
  }

  Uninstall-ChocolateyService -serviceName "$serviceName"

  Remove-ChocolateyDirectory "$testDirectory"
}