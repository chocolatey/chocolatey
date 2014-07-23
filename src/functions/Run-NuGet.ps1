function Run-NuGet {
param(
  [string] $packageName,
  [string] $source = '',
  [string] $version = ''
)
  Write-Debug "Running 'Run-NuGet' for $packageName with source: `'$source`', version:`'$version`'";
  Write-Debug "___ NuGet ____"

  $srcArgs = Get-SourceArguments $source

  $packageArgs = "install $packageName -Outputdirectory `"$nugetLibPath`" $srcArgs -NonInteractive -NoCache"
  if ($version -notlike '') {
    $packageArgs = $packageArgs + " -Version $version";
  }

  if ($prerelease -eq $true) {
    $packageArgs = $packageArgs + " -Prerelease";
  }
  $logFile = Join-Path $nugetChocolateyPath 'install.log'
  $errorLogFile = Join-Path $nugetChocolateyPath 'error.log'

  $result = Execute-Process $nugetExe $packageArgs -returnOutput -returnErrors

  $result.Output | Out-File $logFile
  $result.Errors | Out-File $errorLogFile

  foreach ($line in $result.Output) {
    if ($line -ne $null) {Write-Debug $line;}
  }

  if (-not $result.Errors.IsNullOrEmpty) {
    Throw $errors
  }

  if ($result.Output.IsNullOrEmpty -and $result.Errors.IsNullOrEmpty) {
    $noExecution = 'Execution of NuGet not detected. Please make sure you have .NET Framework 4.0 installed and are passing arguments to the install command.'
    #write-host  -BackgroundColor Red -ForegroundColor White
    Throw $noExecution
  }

  return $result.Output
}
