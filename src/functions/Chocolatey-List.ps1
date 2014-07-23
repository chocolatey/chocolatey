function Chocolatey-List {
param(
  [string] $selector='',
  [string] $source='',
  [switch] $returnOutput = $false
)
  Write-Debug "Running 'Chocolatey-List' with selector: `'$selector`', source:`'$source`'";

  if ($source -like 'webpi') {
    $chocoInstallLog = Join-Path $nugetChocolateyPath 'chocolateyWebPIList.log';
    $webpiArgs ="/c webpicmd /List /ListOption:All"
    Start-ChocolateyProcessAsAdmin "cmd.exe $webpiArgs | Tee-Object -FilePath `'$chocoInstallLog`';" -nosleep
    Create-InstallLogIfNotExists $chocoInstallLog
    $installOutput = Get-Content $chocoInstallLog -Encoding Ascii
    foreach ($line in $installOutput) {
      Write-Host $line
    }
  } elseif ($source -like 'windowsfeatures') {
    $dism = "$env:WinDir\System32\dism.exe"
    if (Test-Path "$env:WinDir\sysnative\dism.exe") {
      $dism = "$env:WinDir\sysnative\dism.exe"
    }

    $chocoInstallLog = Join-Path $nugetChocolateyPath 'chocolateyWindowsFeaturesInstall.log';
    Append-Log $chocoInstallLog
    $windowsFeaturesArgs ="/c $dism /online /get-features /format:table | Tee-Object -FilePath `'$chocoInstallLog`';"
    Start-ChocolateyProcessAsAdmin "cmd.exe $windowsFeaturesArgs" -nosleep
    Create-InstallLogIfNotExists $chocoInstallLog
    $installOutput = Get-Content $chocoInstallLog -Encoding Ascii
    foreach ($line in $installOutput) {
      Write-Host $line
    }
  } else {
    $params = @()
    $params += 'list'
    $parameters = "list"
    if ($selector -ne '') {
      $params += "`"$selector`""
    }

    if ($allVersions -eq $true) {
      Write-Debug "Showing all versions of packages"
      $params += '-all'
    }

    if ($prerelease -eq $true -or $localonly -eq $true -or $source -eq $nugetLibPath) {
      Write-Debug "Showing prerelease versions of packages"
      $params += '-Prerelease'
    }

    if ($verbosity -eq $true) {
      $params += '-verbosity', 'detailed'
    }
    $params += '-NonInteractive'

    if ($localonly) {
      $source = $nugetLibPath
    }

    if ($source -ne '') {
      $params += '-Source', "`"$source`""
    } else {
      $srcArgs = Get-SourceArguments $source
      if ($srcArgs -ne '') {
        $srcArgs = $srcArgs.Replace('-Source ','')
        $params += '-Source', "$srcArgs" #already quoted from Get-SourceArguments
      }
    }

    Write-Debug "Executing command [`"$nugetExe`" $params]"
    $packageList = @{}

    $result = Execute-Process $nugetExe $params -returnOutput:$returnOutput -returnErrors:$returnOutput

    if (-not $result.output.IsNullOrEmpty) {
        $lines = ($result.output -split "\r\n")
        foreach ($line in $lines) {
            $package = $line.Split(" ")
            $packageList.Add("$($package[0])","$($package[1])")
        }
    }

    Write-Debug "Command [`"$nugetExe`" $params] exited with `'$($result.ExitCode)`'."

    if ($returnOutput) {
      # not a bug
      return ,$packageList
    }
  }
}
