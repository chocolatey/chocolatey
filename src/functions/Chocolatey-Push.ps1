﻿function Chocolatey-Push {
param(
  [string] $packageName, 
  [string] $source = 'http://chocolatey.org/' 
)

  $srcArgs = "-source $source"

  $packageArgs = "push $packageName $srcArgs"
  $logFile = Join-Path $nugetChocolateyPath 'push.log'
  $errorLogFile = Join-Path $nugetChocolateyPath 'error.log'
  
  Write-Host "Calling `'$nugetExe $packageArgs`'. This may take a few minutes. Please wait for the command to finish."
  
  Start-Process $nugetExe -ArgumentList $packageArgs -NoNewWindow -Wait -RedirectStandardOutput $logFile -RedirectStandardError $errorLogFile

  $nugetOutput = Get-Content $logFile -Encoding Ascii
  foreach ($line in $nugetOutput) {
    Write-Host $line
  }
  $errors = Get-Content $errorLogFile
  if ($errors -ne '') {
    Write-Host $errors -BackgroundColor Red -ForegroundColor White
    #throw $errors
  }
}