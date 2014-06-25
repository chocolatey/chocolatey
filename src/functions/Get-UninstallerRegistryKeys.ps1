
# Leaning on info from http://community.spiceworks.com/how_to/show/2238-how-add-remove-programs-works
# But ignoring WindowsInstaller value - seems set to 1 in some standard programs
filter script:GoodUninstallKey {
 if ($_.GetValue('DisplayName') -and $_.GetValue('UninstallString') -and $_.GetValue('SystemComponent', 0) -eq 0 `
    -and !$_.GetValue('ParentKeyName') -and !$_.GetValue('ReleaseType') -and $_.PSChildName -notmatch "KB\d{6}")
  { $_ }
}

function Get-UninstallerRegistryKeys {
param(
  [string]$outFile
)
  if ([intptr]::Size -eq 4 -and (Test-Path "$env:windir\sysnative")) {
    # We're in 32-bit mode on a 64-bit box - need to upgrade myself for consistency and to catch any 64-bit installer activity
    # This would have been much easier/cleaner in Powershell 3.0 with RegistryView, but we're sticking with Powershell v2...
    # Looked/tried a few methods, but the most reliable seemed to be via recalling in 64-bit form and sending back via a temporary CSV file
    $mypath = Join-Path "$env:ChocolateyInstall" 'functions\Get-UninstallerRegistryKeys.ps1'
    $tmpFile = [System.IO.Path]::GetTempFileName()
    & "$env:windir\sysnative\WindowsPowerShell\v1.0\powershell.exe" -command "& { . '$mypath'; Get-CompoundUninstallerKeys('$tmpFile') }"
    # Import-Csv has no Encoding param in Powershell v2
    $keys = Get-Content $tmpFile -Encoding UTF8 | ConvertFrom-Csv
    Remove-Item $tmpFile
    return $keys
  } else {
    $currentSID = [System.Security.Principal.WindowsIdentity]::GetCurrent().User
    $keys = @()
    @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall', 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall',
      'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall', 'HKCU:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall') | ForEach-Object {
      if (Test-Path $_) {
        $significantUser = ''
        if ($_.StartsWith('HKCU:')) {
          $significantUser = $currentSID
        }
        Get-ChildItem -Path $_ | GoodUninstallKey | ForEach-Object {
          $uninstallCommand = $_.GetValue('QuietUninstallString', '')
          if (!($uninstallCommand)) {
            $uninstallCommand = $_.GetValue('UninstallString')
          }
          $keys += New-Object PSObject -Property @{Key = $_.Name; DisplayName = $_.GetValue('DisplayName'); SignficantUser = $significantUser; UninstallCommand = $uninstallCommand}
        }
      }
    }
    if ($outFile) {
      $keys | Export-CSV $outFile -Encoding UTF8 -Force
    } else {
      return $keys
    }
  }
}
