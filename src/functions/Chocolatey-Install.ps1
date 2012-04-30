function Chocolatey-Install {
param(
  [string] $packageName, 
  [string] $source = '', 
  [string] $version = '',
  [string] $installerArguments = ''
)
  
  if($($packageName).EndsWith('.config')) {
    Chocolatey-PackagesConfig $packageName
    return
  }
  
  switch -wildcard ($source) 
  {
    "webpi" { Chocolatey-WebPI $packageName $installerArguments; }
    "ruby" { Chocolatey-RubyGem $packageName $version $installerArguments; }
    default { Chocolatey-NuGet $packageName $source $version; }
  }
}