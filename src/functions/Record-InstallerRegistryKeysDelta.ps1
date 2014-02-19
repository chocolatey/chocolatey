function Record-InstallerRegistryKeysDelta {
param(
  [string] $packageName,
  [string] $packageFolder,
  [PSObject[]] $beforeRegKeys,
  [PSObject[]] $afterRegKeys
)

  $significantRegKeys = $afterRegKeys | Where-Object {
    foreach ($old in $beforeRegKeys) {
      if ($old.Key -eq $_.Key -and $old.DisplayName -eq $_.DisplayName -and $old.UninstallCommand -eq $_.UninstallCommand) { return $false }
    }
    $true
  }

  if ($significantRegKeys) {
    Write-Host "Logging item(s) from Add/Remove Programs registry for future auto-uninstall:"
    $significantRegKeys | ForEach-Object { Write-Host $_.DisplayName; Write-Debug $_ }

    $uninstallKeysFile = join-path "$packageFolder" "$packageName-uninstallkeys.txt"
    $significantRegKeys | Export-CSV $uninstallKeysFile -Encoding UTF8 -NoTypeInformation -Force
  }
}
