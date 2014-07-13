function Remove-ChocolateyDirectory {
param(
  [string] $directory
)
  Write-Host "Directory `"$directory`" will be removed"
  
  if (Test-Path $directory) {
    Remove-Item -Recurse -Force $directory
  }
}