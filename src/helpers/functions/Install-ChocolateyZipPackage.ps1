function Install-ChocolateyZipPackage {
<#
.SYNOPSIS
Downloads and unzips a package

.DESCRIPTION
This will download a file from a url and unzip it on your machine.

.PARAMETER PackageName
The name of the package we want to download - this is arbitrary, call it whatever you want.
It's recommended you call it the same as your nuget package id.

.PARAMETER Url
This is the url to download the file from.

.PARAMETER Url64bit
OPTIONAL - If there is an x64 installer to download, please include it here. If not, delete this parameter

.PARAMETER UnzipLocation
This is a location to unzip the contents to, most likely your script folder.

.EXAMPLE
Install-ChocolateyZipPackage '__NAME__' 'URL' "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

.OUTPUTS
None

.NOTES
This helper reduces the number of lines one would have to write to download and unzip a file to 1 line.
This method has error handling built into it.

.LINK
  Get-ChocolateyWebFile
  Get-ChocolateyUnzip
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
  if(!$packageName) {
    Write-ChocolateyFailure "Install-ChocolateyZipPackage" "Missing PackageName input parameter."
    return
  }
  
  if(!$url) {
    Write-ChocolateyFailure "Install-ChocolateyZipPackage" "Missing Url input parameter."
    return
  }

  if(!$unzipLocation) {
    Write-ChocolateyFailure "Install-ChocolateyZipPackage" "Missing UnzipLocation input parameter."
    return
  }

  Write-Debug "Running 'Install-ChocolateyZipPackage' for $packageName with url:`'$url`', unzipLocation: `'$unzipLocation`', url64bit: `'$url64bit`', specificFolder: `'$specificFolder`', checksum: `'$checksum`', checksumType: `'$checksumType`', checksum64: `'$checksum64`', checksumType64: `'$checksumType64`' ";

  try {  
    $fileType = 'zip'
    $chocTempDir = Join-Path $env:TEMP "chocolatey"
    $tempDir = Join-Path $chocTempDir "$packageName"
    if (![System.IO.Directory]::Exists($tempDir)) {[System.IO.Directory]::CreateDirectory($tempDir) | Out-Null}
    $file = "$($packageName)Install.$fileType"
	$filePath = Join-Path $tempDir "$file"
	
    Get-ChocolateyWebFile $packageName $filePath $url $url64bit -checkSum $checkSum -checksumType $checksumType -checkSum64 $checkSum64 -checksumType64 $checksumType64
	
	if (($url -match 'tar.gz') -or ($url64bit -match 'tar.gz')){ 
	  Invoke-Expression -Command:"cinst Cygwin"
	
	  $unzipLocationTar = "$unzipLocation" -replace "\\","/"
      Set-Location $tempDir

      if (!(Test-Path $unzipLocationTar)) {
        new-item $unzipLocationTar -itemtype directory
      }
      
	  Invoke-Expression -Command:"tar xvzf $file -C $unzipLocationTar"
	} else {
	  Get-ChocolateyUnzip "$filePath" $unzipLocation $specificFolder $packageName
    }

    Write-ChocolateySuccess $packageName
  } catch {
    Write-ChocolateyFailure $packageName $($_.Exception.Message)
    throw
  }
}

set-alias Install-ChocolateyArchivePackage Install-ChocolateyZipPackage