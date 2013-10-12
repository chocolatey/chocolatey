$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path $here '_Common.ps1'
. $common

Describe "When calling Chocolatey-NuGet normally" {
  Mock Update-SessionEnvironment
  Mock Run-NuGet {""} -Verifiable -ParameterFilter {$packageName -eq 'somepackage'}
  
  Chocolatey-NuGet 'somepackage'
  
  It "should call Run-NuGet" {
    Assert-VerifiableMocks
  }  
}

Describe "when calling Chocolatey-NuGet with packageName 'all'" {
  Update-SessionEnvironment
  Mock Chocolatey-InstallAll {} -Verifiable -ParameterFilter {$source -eq 'source'}

  Chocolatey-NuGet 'all' 'source'

  It "should call Chocolatey-InstallAll" {
    Assert-VerifiableMocks
  }
  
}

Describe "when calling Chocolatey-Nuget with empty packageName"{
  Update-SessionEnvironment
  Mock Write-Debug 

  Chocolatey-Nuget ''
  It "should fail for an empty package"{
    Assert-MockCalled Write-Debug -ParameterFilter {$message -like "No package to run, aborting"}
  }

}
