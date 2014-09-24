function Chocolatey-Install {
param(
  [string] $packageName,
  [string] $source = '',
  [string] $version = '',
  [string] $installerArguments = ''
)
  Write-Debug "Running 'Chocolatey-Install' for `'$packageName`' with source: `'$source`', version: `'$version`', installerArguments:`'$installerArguments`'";

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
    default 
    {
      if ([string]::IsNullOrEmpty($version))
      {
	$nversions = Chocolatey-List -selector "$packageName" -returnOutput
	foreach ($nversion in $nversions.GetEnumerator()) 
	{
	  if ($nversion -ne $null)
	  {
	    Chocolatey-NuGet $nversion.name $source $nversion.value $installerArguments;
	  } 
	  else
	  {
	    Write-Debug "$($nversion.name) - package not found!"
	  }
	}
      }
      else
      {
      	Chocolatey-Nuget $packageName $source $version $installerArguments;
      }
    }
  }
}
