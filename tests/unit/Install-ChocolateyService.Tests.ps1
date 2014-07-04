$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
$base = Split-Path -parent (Split-Path -Parent $here)
. $common
. "$base\src\helpers\functions\Install-ChocolateyService.ps1"

Describe "Install-ChocolateyService" {
	Context "When no packageName parameter is passed to this function" {
		Mock Write-ChocolateyFailure
		
		Install-ChocolateyService
		
		It "should return an error" {
			Assert-MockCalled Write-ChocolateyFailure -parameterFilter { $failureMessage  -eq "Missing PackageName input parameter." }
		}
	}
}