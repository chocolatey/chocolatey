function Get-ChocolateyPackageRoot {


  $ChocolateyPackageRoot = ''

  if ($env:ChocolateyPackageRoot -ne $null) {
    $ChocolateyPackageRoot = $env:ChocolateyPackageRoot
  }

  $ConfigPackageRoot  = Get-ConfigValue 'ChocolateyPackageRoot'
  
  if ($ConfigPackageRoot) {
    $ChocolateyPackageroot = $ConfigPackageRoot
  }

  return $ChocolateyPackageRoot
}
