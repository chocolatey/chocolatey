

function UnInstall-ChocolateyPath {
param(
	[string] $pathToUnInstall,
	[System.EnvironmentVariableTarget] $pathType = [System.EnvironmentVariableTarget]::User
)
	Write-Debug "Running 'UnInstall-ChocolateyPath' with pathToUnInstall:`'$pathToUnInstall`'";
	$originalPathToUnInstall = $pathToUnInstall

	#get the PATH variable
	$envPath = $env:PATH
	if ($envPath.ToLower().Contains($pathToUnInstall.ToLower()))
	{
		$statementTerminator = ";"
		Write-Host "PATH environment variable contains $pathToUnInstall. Removing..."
		$actualPath = [System.Collections.ArrayList](Get-EnvironmentVariable -Name 'Path' -Scope $pathType).split($statementTerminator)
	
		$actualPath.Remove($pathToUnInstall)	
		$newPath =  $actualPath -Join $statementTerminator
	
		if ($pathType -eq [System.EnvironmentVariableTarget]::Machine) {
			if (Test-ProcessAdminRights) {
				Set-EnvironmentVariable -Name 'Path' -Value $newPath -Scope $pathType
			} else {
				$psArgs = "UnInstall-ChocolateyPath -pathToUnInstall `'$originalPathToUnInstall`' -pathType `'$pathType`'"
				Start-ChocolateyProcessAsAdmin "$psArgs"
			}
		} else {
			Set-EnvironmentVariable -Name 'Path' -Value $newPath -Scope $pathType
		}
	} else {
		Write-Debug " The path to uninstall `'$pathToUnInstall`' was not found in the `'$pathType`' PATH. Could not remove."
	}
}
