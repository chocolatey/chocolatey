function Get-TempDir {
  Write-Debug "Running 'Get-TempDir'"

  $tempDir = Get-ConfigValue 'tempDir' $env:TEMP
  $tempDir = [Environment]::ExpandEnvironmentVariables($tempDir)
  return $tempDir
}