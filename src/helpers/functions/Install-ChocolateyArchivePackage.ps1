function Install-ChocolateyArchivePackage {
<#
.SYNOPSIS
AKA Install-ChocolateyZipPackage
#>
param(
  [string] $packageName,
  [string] $url,
  [string] $unzipLocation,
  [string] $url64bit = $url,
  [string] $specificFolder ="",
  [string] $checksum = '',
  [string] $checksumType = '',
  [string] $checksum64 = '',
  [string] $checksumType64 = ''
)
  Install-ChocolateyZipPackage $packageName $url $unzipLocation $url64bit $specificFolder $checksum $checksumType $checksum64 $checksumType64
}


