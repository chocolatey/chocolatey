function Chocolatey-AutoUninstall {
<#
.SYNOPSIS
Uninstalls a package automatically

.DESCRIPTION
This will attempt to uninstall a package on your machine using information recorded during the install.

.PARAMETER PackageFolder
The folder the package installed to

.PARAMETER PackageName
The name of the package

.EXAMPLE
Chocolatey-AutoUninstall '__FOLDER__' '__NAME__'

.OUTPUTS
None

.NOTES

.LINK
Install-ChocolateyInstallPackage
#>
param(
  [string] $packageFolder,
  [string] $packageName
)
  Write-Debug "Running 'Chocolatey-AutoUninstall' for $packageName in $packageFolder";

  $uninstallKeysFile = join-path "$packageFolder" "$packageName-uninstallkeys.txt"
  if (!(Test-Path $uninstallKeysFile)) {
    throw "This package has a chocolateyInstall.ps1 without a chocolateyUninstall.ps1, and auto-uninstall failed. You will need to manually reverse whatever steps the installer did. Please ask the package maker to include a chocolateyUninstall.ps1 in the file to really remove the package."
  }

  write-host "Auto-uninstalling $packageName..."

  # Import-Csv has no Encoding param in Powershell v2
  # In powershell v2, need to force result of ConvertFrom-Csv to an array in case only one line in file
  $uninstallKeys = @(Get-Content $uninstallKeysFile -Encoding UTF8 | ConvertFrom-Csv)

  if ($uninstallKeys -eq $nil -or $uninstallKeys.Length -eq 0) {
    throw "Blank auto-install information - you will need to manually uninstall $($packageName)."
  }

  $currentSID = [System.Security.Principal.WindowsIdentity]::GetCurrent().User
  foreach ($uk in $uninstallKeys) {
    if (($uk.SignficantUser) -and $($uk.SignficantUser -ne $currentSID)) {
      Write-Debug "SID-clash: $($uk.SignficantUser) vs. $currentSID with $($uk.DisplayName), $($uk.Key)"
      $otherSID = New-Object System.Security.Principal.SecurityIdentifier($uk.SignficantUser) 
      $otherUser = $otherSID.Translate([System.Security.Principal.NTAccount]) 
      throw "$packageName was installed per-user under $($otherUser.Value) account - switch to that user before uninstalling"
    }
  }

  $allUninstallKeys = Get-UninstallerRegistryKeys

  $uninstallKeys | ForEach-Object {
    Write-Debug "Attempting uninstall via $_"
    $found = $false
    foreach ($now in $allUninstallKeys) {
      if ($now.Key -eq $_.Key) {
        $found = $true
        if ($now.DisplayName -ne $_.DisplayName) {
          Write-Host "Note: About to uninstall $($now.DisplayName), which was $($_.DisplayName) at install time"
        } else {
          Write-Host "Auto-uninstalling $($_.DisplayName) Add/Remove Programs entry"
        }
        $uninstallCommand = $now.UninstallCommand
        Write-Debug "Uninstall command: $uninstallCommand"
        if ($uninstallCommand -ne $_.UninstallCommand) {
          Write-Debug "Note: Uninstall command was different at install time: $($_.UninstallCommand)"
        }

        # Massage msiexec to silent uninstalls
        if ($uninstallCommand -match "^msiexec.exe\s+/[ix]\s*({[A-Z0-9\-]+})") {
          $uninstallCommand = "msiexec.exe /x$($Matches[1]) /quiet"
          Write-Debug "Updating MSI uninstall to be quiet with: $uninstallCommand"
        }

        # Split into program and args
        if ($uninstallCommand.StartsWith("""")) {
          $pos = $uninstallCommand.IndexOf('"', 1)
          if ($pos -lt 0 ) { throw "Corrupt Uninstall command - unclosed quotes" }
          $program = $uninstallCommand.Substring(1, $pos-1).Trim()
          $args = $uninstallCommand.Substring($pos+1).Trim()
        } else {
          $pos = $uninstallCommand.IndexOf(' ', 1)
          if ($pos -lt 0 ) {
              $program = $uninstallCommand
              $args = ''
          } else {
              $args = $uninstallCommand.Substring($pos+1).Trim()
              $program = $uninstallCommand.Substring(0, $pos).Trim()
          }
        }
        Write-Debug "Split into $program and $args"

        $validExitCodes = @(0)
        Start-ChocolateyProcessAsAdmin "$args" $program -validExitCodes $validExitCodes

        $found = $true
        break;
      }
    }
    if (!($found)) {
      Write-Host "Ignoring already deleted uninstall key $($_.Key), aka $($_.DisplayName)"
    }
  }

  write-host "$packageName has been auto-uninstalled."
}