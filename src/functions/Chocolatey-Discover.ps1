function Chocolatey-Discover {
param(
  [parameter(mandatory=$true)][string] $source,
  [parameter(mandatory=$true)][string] $provides
)

  Write-Debug "Running 'Chocolatey-Discover' for $packageName with source:`'$source`', version: `'$version`', provides: `'$provides`'";

  # quick pseudo-code
  ## try to find the package by provides, which is a semi-colon (for consistency) delimited list of executables that the package could be provided by
  
  
}
