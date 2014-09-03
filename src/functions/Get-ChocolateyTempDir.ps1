function Get-ChocolateyTempDir {
  Write-Debug "Running 'Get-ChocolateyTempDir'";

  $chocTempDir = Join-Path (Get-TempDir) "chocolatey"
  return $chocTempDir
}
