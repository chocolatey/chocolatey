function Uninstall-ChocolateyPath {
param(
  [string] $sPathToUninstall,
  [System.EnvironmentVariableTarget] $sPathType = [System.EnvironmentVariableTarget]::User
)
Write-Debug "Running 'Uninstall-ChocolateyPath' with path to uninstall as:`'$sPathToUninstall`'";
Write-Host "PATH environment variable has $sPathToUninstall in it. Removing..."

$sShellPath = $env:PATH
$sCurrentPath = Get-EnvironmentVariable -name "Path" -scope $sPathType
$sPathToUninstall = [regex]::Escape($sPathToUninstall)


$sShellPath = $sShellPath -replace "(;)?$sPathToUninstall(;)?$", "" `
						-replace "$sPathToUninstall(;)?", ""
$sCurrentPath = $sCurrentPath -replace "(;)?$sPathToUninstall(;)?$", "" `
						-replace "$sPathToUninstall(;)?", ""

$env:PATH = $sShellPath
Set-EnvironmentVariable "Path" $sCurrentPath $sPathType
}
