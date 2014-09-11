<#
Author: Ben Brewer <ben@benbrewer.me>
Description: A cache initializer that downloads .nupkg files from a web repository and places them in a
local cache for reference by NuGet. This is to help get around situations where installing a RESTful API
for a private NuGet repository is not possible.
NOTE: all failures throw and expect a reasonable amount of cleanup.
#>

function Update-Cache {
param(
  [parameter(mandatory=$true)][object] $source
)
	# member variables - script: is script scope
	$script:sSourcePath = $source.value
	$script:sDestinationPath = $env:ChocolateyInstall + "\cache\" + $source.id
	$script:sPackageConfigFile = ""
	$script:wClient = $null
	
	Write-Debug "Running 'Update-Cache' with source:'$sSourcePath' and cache:'$script:sDestinationPath'"
	
	# validation - check the source path
	Write-Host "Validating source type as a web cache for source '$($source.id)'"
	Update-Cache-Validate-Source-Type $script:sSourcePath
	
	# fix-up the cache directory	
	Write-Host "Initializing cache in $script:sDestinationPath"
	Update-Cache-Init-Folder $script:sDestinationPath
		
	# set up web client, which will be doing the work
	Write-Host "Initializing connection to $sSourcePath"
	Update-Cache-Init-Web-Client
	
	# download the package.conf from the source
	Write-Host "Downloading package configuration for source '$($source.id)'"
	Update-Cache-Download-Package-Config
	
	# load up the package configuration
	Write-Host "Downloading packages for source '$($source.id)'"
	Update-Cache-Parse-Package-Config
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
function Update-Cache-Init-Web-Client {
	$script:wClient = New-Object System.Net.Webclient	
	$bCredentialsExist = $sSourcePath -match "(?://)(\w+):(\w+)(?:@)"
	if ($bCredentialsExist) {  
		$script:wClient.Credentials = New-Object System.Net.NetworkCredential($matches[1],$matches[2])
	}
}
function Update-Cache-Download-Package-Config {
	$sSourcePackageConfigFile = $sSourcePath + "/packages.config"
	$script:sPackageConfigFile = $script:sDestinationPath + "\packages.config"
	
	Write-Debug "'Update-Cache' downloading $sSourcePackageConfigFile to $script:sPackageConfigFile"
	$script:wClient.DownloadFile($sSourcePackageConfigFile,$script:sPackageConfigFile)
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
	$script:wClient.DownloadFile($sSourcePackageFile,$sDestinationPackageFile)
}


