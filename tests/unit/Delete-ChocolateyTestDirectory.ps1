function Delete-ChocolateyTestDirectory {
param(
  [string] $testDirectory
)
  Write-Host "Remove test directory $testDirectory after finishing testing"
  
  if (Test-Path $testDirectory) {
    Remove-Item -Recurse -Force $testDirectory
  }
}