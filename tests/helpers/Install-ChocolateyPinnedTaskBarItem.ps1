function Install-ChocolateyPinnedTaskBarItem {
param(
  [string] $targetFilePath
)

  $script:Install-ChocolateyPinnedTaskBarItem_was_called = $true
  $script:targetFilePath = $targetFilePath
  
  if ($script:exec_install_ChocolateyPinnedTaskBarItem_actual) { Install-ChocolateyPinnedTaskBarItem-Actual @PSBoundParameters}
}