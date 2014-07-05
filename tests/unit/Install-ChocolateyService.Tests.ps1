$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
$base = Split-Path -parent (Split-Path -Parent $here)
. $common
. "$base\src\helpers\functions\Install-ChocolateyService.ps1"

Describe "Install-ChocolateyService" {
	Context "When no packageName parameter is passed to this function" {
		Mock Write-ChocolateyFailure
		
		Install-ChocolateyService -serviceName "TestWorkingDiectory" -createServiceCommand "TestArguments" -availablePort "1"
		
		It "should return an error" {
			Assert-MockCalled Write-ChocolateyFailure -parameterFilter { $failureMessage  -eq "Missing PackageName input parameter." }
		}
	}
	
	Context "When no serviceName parameter is passed to this function" {
		Mock Write-ChocolateyFailure
		
		Install-ChocolateyService -packageName "TestTargetPath" -createServiceCommand "TestArguments" -availablePort "1"
		
		It "should return an error" {
			Assert-MockCalled Write-ChocolateyFailure -parameterFilter { $failureMessage  -eq "Missing ServiceName input parameter." }
		}
	}

	Context "When no createServiceCommand parameter is passed to this function" {
		Mock Write-ChocolateyFailure
		
		Install-ChocolateyService -packageName "TestTargetPath" -serviceName "TestWorkingDiectory" -availablePort "1"
		
		It "should return an error" {
			Assert-MockCalled Write-ChocolateyFailure -parameterFilter { $failureMessage  -eq "Missing CreateServiceCommand input parameter." }
		}
	}

	Context "When no availablePort parameter is passed to this function" {
		Mock Write-ChocolateyFailure
		
		Install-ChocolateyService -packageName "TestTargetPath" -serviceName "TestWorkingDiectory" -createServiceCommand "TestArguments"
		
		It "should return an error" {
			Assert-MockCalled Write-ChocolateyFailure -parameterFilter { $failureMessage  -eq "Missing AvailablePort input parameter." }
		}
	}	
	
	Context "When createService parameter is incorrect" {
		Mock Write-ChocolateyFailure
		
		Install-ChocolateyService -packageName "helloworld" -serviceName "helloworld"  -createServiceCommand "c:\helloworld" -availablePort "135"
		
		It "should return an error" {
			Assert-MockCalled Write-ChocolateyFailure -parameterFilter { $failureMessage  -eq "service helloworld does not exist."
Write-host $failureMessage
			}
		}
	}	
	
	
	
#	Context "When all parameters are passed with valid values" {
#		$shortcutPath = "c:\test.lnk"
#        $targetPath = "C:\test.txt"
#		$workingDirectory = "C:\"
#		$arguments = "args"
#		$iconLocation = "C:\test.ico"
#		$description = "Description"

#        Set-Content $targetPath -value "my test text."
#		Set-Content $iconLocation -Value "icon"

#		Install-ChocolateyShortcut -shortcutFilePath $shortcutPath -targetPath $targetPath -workDirectory $workingDirectory -arguments $arguments -iconLocation $iconLocation -description $description
#		Install-ChocolateyService -packageName "helloworld" -serviceName "helloworld"  -createServiceCommand "c:\" -availablePort "1"
		
 #       $result = Test-Path($shortcutPath)
		
#		It "should succeed." {
#		}
		
        # Tidy up items that were created as part of this test
 #       if(Test-Path($shortcutPath)) {
  #          Remove-Item $shortcutPath
   #     }

    #    if(Test-Path($targetPath)) {
     #       Remove-Item $targetPath
      #  }		
		
#		if(Test-Path($iconLocation)) {
#			Remove-Item $iconLocation
#		}
#	}
}