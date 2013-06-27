function Remove-BinFile {
<#
.SYNOPSIS 
    Removes the wrapper batch and bash shell file of an executable
.PARAMETER name
    The basename of the batch and bash shell files
.PARAMETER path
    The full path of the executable to set the batch and bash shell files for
.PARAMETER outPath
    The folder to remove the wrapper batch and bash shell files from
#>
[CmdletBinding()]
param(
  [string] $name, 
  [string] $path,
  [string] $outPath
)
  Write-Debug "Running 'Remove-BinFile' for $name with path:`'$path`'";

  $packageBatchFileName = Join-Path $outPath "$name.bat"
  $packageBashFileName = Join-Path $outPath "$name"
  $path = $path.ToLower().Replace($outPath.ToLower(), "%DIR%..\").Replace("\\","\")
  $pathBash = $path.Replace("%DIR%..\","`$DIR/../").Replace("\","/")
  Write-Debug "Attempting to remove the batch and bash shortcuts: $packageBatchFileName and $packageBashFileName"
  if (Test-Path $packageBatchFileName) {
    Write-Host "Removing batch file $packageBatchFileName which pointed to `'$path`'." -ForegroundColor $Note
    Remove-Item $packageBatchFileName
  }
  else {
    Write-Host "Tried to remove batch file $packageBatchFileName but it was already removed." -ForegroundColor $Note
  }
  if (Test-Path $packageBashFileName) {
    Write-Host "Removing bash file $packageBashFileName which pointed to `'$path`'." -ForegroundColor $Note
    Remove-Item $packageBashFileName
  }
  else {
    Write-Host "Tried to remove bash file $packageBashFileName but it was already removed." -ForegroundColor $Note
  }
}
