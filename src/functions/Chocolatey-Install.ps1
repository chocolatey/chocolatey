function Chocolatey-Install {
param(
  [string] $packageName,
  [string] $source = '',
  [string] $version = '',
  [string] $installerArguments = ''
)
  if($packageName -eq 'help'){
@"
$h1
Help for chocolatey install command
$h1
$h2
Usage
$h2

chocolatey [install [packageName [-source source] [-version version] | pathToPackagesConfig]

$h2
More Information
$h2

In addition to specifying custom nuget sources, you may also specify that you would like to install your component via the package manager of any of the following:
* webpi
* windowsfeatures
* cygwin
* python
* ruby

You can also operate against these alternate sources as follows:

chocolatey python packageName

or use the shortcut: cpython

Use chocolatey help python for more information

$h2
Examples
$h2

chocolatey install nunit
chocolatey install nunit -version 2.5.7.10213
chocolatey install packages.config
chocolatey install bash -source cygwin

$h2
Shorcut
$h2

cinst [arguments]

"@ | Write-Host
    Write-Host 'Enter H to go to online help, or any other key to quit'
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

    if($x.Character -eq 'h')
    {
      Invoke-Expression “cmd.exe /C start https://github.com/chocolatey/chocolatey/wiki/CommandsInstall”
    }
    return
  }
  Write-Debug "Running 'Chocolatey-Install' for $packageName with source: `'$source`', version: `'$version`', installerArguments:`'$installerArguments`'";

  if($($packageName).EndsWith('.config')) {
    Write-Debug "Chocolatey-Install has determined that package $packageName ends with `'.config`' - calling Chocolatey-PackagesConfig"
    Chocolatey-PackagesConfig $packageName
    return
  }

  switch -wildcard ($source)
  {
    "webpi" { Chocolatey-WebPI $packageName $installerArguments; }
    "windowsfeatures" { Chocolatey-WindowsFeatures $packageName; }
    "cygwin" { Chocolatey-Cygwin $packageName $installerArguments; }
    "python" { Chocolatey-Python $packageName $version $installerArguments; }
    "ruby" { Chocolatey-RubyGem $packageName $version $installerArguments; }
    default {Invoke-ChocolateyFunction "Chocolatey-Nuget" @($packageName,$source,$version,$installerArguments)}
  }
}
