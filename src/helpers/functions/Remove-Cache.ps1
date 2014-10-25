<#
Author: Ben Brewer <ben@benbrewer.me>
Description: A very simple cache remover that is fairly tightly coupled with Update-Cache function.
NOTE: all failures throw and expect a reasonable amount of cleanup.
#>
function Remove-Cache {
param(
  [parameter(mandatory=$true)][object] $source,
  [parameter(mandatory=$true)][object] $nugetPath
)
	# quick internal logic to exit early
	if ($source.type -ne 'cache') { return }

	# member variables - script: is script scope
	$script:sCachePath = $nugetPath + "\cache\" + $source.id
			
	Write-Debug "Running 'Remove-Cache' with cache:'$script:sCachePath'"
	
	if ([System.IO.Directory]::Exists($sCachePath)) {
		Remove-Item $sCachePath -recurse | Out-Null
	}
}

