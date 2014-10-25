<#
Author: Ben Brewer <ben@benbrewer.me>
Description: A cache initializer that downloads .nupkg files from a web directory and places them in a
local cache for reference by NuGet. This is to help get around situations where installing a RESTful API
for a private NuGet repository is not possible.
#>

function Update-Cache {
param(
  [parameter(mandatory=$true)][object] $source,
  [parameter(mandatory=$true)][object] $nugetPath
)
	# quick internal logic to exit early
	if ($source.type -ne 'cache') { return }
	try {			
		# member variables - script: is script scope
		$script:sSourcePath = $source.value
		$script:sDestinationPath = $nugetPath + "\cache\" + $source.id
		$script:sPackageConfigFile = ""
		
		Write-Debug "Running 'Update-Cache' with source:'$sSourcePath' and cache:'$script:sDestinationPath'"
		
		# validation - check the source path
		Write-Host "Validating source type as a web cache for source '$($source.id)'"
		Update-Cache-Validate-Source-Type $script:sSourcePath
		
		# fix-up the cache directory	
		Write-Host "Initializing cache in $script:sDestinationPath"
		Update-Cache-Init-Folder $script:sDestinationPath
				
		# download the package.conf from the source
		Write-Host "Downloading package configuration for source '$($source.id)'"
		Update-Cache-Download-Package-Config
		
		# load up the package configuration
		Write-Host "Downloading package descriptors for source '$($source.id)'"
		Update-Cache-Parse-Package-Config			
	}
	catch {
		Write-Host "Source '$($source.id)' unable to cache. Cache will be removed. Please debug for more information."
		Remove-Cache $source
	}	
}
function Update-Cache-Validate-Source-Type {
param(
  [parameter(mandatory=$true)][string] $sSourcePath
)
	$bIsWebResource = $sSourcePath -imatch "^http(?:s)?://.*$"
	if (-not $bIsWebResource) { throw "Please ensure that source path is a web resource (reached via http or https)" }
}
function Update-Cache-Init-Folder {
param(
  [parameter(mandatory=$true)][string] $sFolderPath
)
	if (![System.IO.Directory]::Exists($sFolderPath)) {
		[System.IO.Directory]::CreateDirectory($sFolderPath) | Out-Null
	}
	else {
		Remove-Item $sFolderPath\* -recurse | Out-Null
	}
}
function Update-Cache-Download-Package-Config {
	$sSourcePackageConfigFile = $sSourcePath + "/packages.config"
	$script:sPackageConfigFile = $script:sDestinationPath + "\packages.config"
	
	Write-Debug "'Update-Cache' downloading $sSourcePackageConfigFile to $script:sPackageConfigFile"
	Get-WebFile $sSourcePackageConfigFile $script:sPackageConfigFile
}

function Update-Cache-Parse-Package-Config {
	$xPackageConfigXml = [xml] (Get-Content $script:sPackageConfigFile)
	[System.Xml.XmlElement] $xPackageConfig = $xPackageConfigXml.get_DocumentElement()
	[System.Xml.XmlElement] $xPackage = $null
	foreach($xPackage in $xPackageConfig.ChildNodes) {
		Update-Cache-Download-Package $xPackage
	}
}

function Update-Cache-Download-Package {
	$sSourcePackageFile = $sSourcePath + "/" + $xPackage.source + "/" + $xPackage.id + "." + $xPackage.version + ".nupkg"
	$sDestinationPackageFile = $script:sDestinationPath + "\" + $xPackage.source + "\" + $xPackage.id + "." + $xPackage.version + ".nupkg"
	$sDestinationPackagePath = $(Split-Path -parent $sDestinationPackageFile)
	
	Update-Cache-Init-Folder $sDestinationPackagePath
	
	Write-Debug "'Update-Cache' downloading $sSourcePackageFile to $sDestinationPackageFile"
	Get-WebFile $sSourcePackageFile $sDestinationPackageFile
}


