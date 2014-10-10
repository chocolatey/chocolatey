$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
. $common

# neither nuget.exe nor Process.Start() will understand TestDrive:\
$nugetLibPath = (Resolve-Path $nugetLibPath).ProviderPath
$nugetExe = "$src\nuget.exe"

Describe "Chocolatey-Version" {

  Context "When called for nonexistent package" {
    Setup -Dir 'chocolatey\chocolateyInstall'
    Copy-Item $src\chocolatey.config $nugetChocolateyPath -Force

    It "should throw an exception" {
        { Chocolatey-Version 'nonexistent-package' } | Should Throw
    }
  }

  Context "When called with no arguments" {
    Setup -Dir 'chocolatey\chocolateyInstall'
    Copy-Item $src\chocolatey.config $nugetChocolateyPath -Force

    It "should not throw an exception" {
        { $script:output = Chocolatey-Version } | Should not Throw
        Write-Debug "Chocolatey-Version output: $script:output"
    }
    It "should return version of chocolatey" {
        $script:output | Should not BeNullOrEmpty
        ($script:output).name | Should Be 'chocolatey'
        ($script:output).found | Should Match '^(\d+\.){3}\d+(-.+)?$'
    }
  }

}
