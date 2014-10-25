<#
Author: Ben Brewer <ben@benbrewer.me>
Description: A very simple source path rewriter that is fairly tightly coupled with Update-Cache function.
NOTE: all failures throw and expect a reasonable amount of cleanup.
#>
function Get-CacheSourceArgument {
param(
  [parameter(mandatory=$true)][object] $source,
  [parameter(mandatory=$true)][object] $nugetPath
)
	Write-Debug "Running 'Get-CacheSourceArgument' for '$($source.id)'"
	if ($source.type -eq "cache") {
		$nugetPath + "\cache\" + $source.id
	}
	else {
		$source.value
	}
}

