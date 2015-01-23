function Install-ChocolateyServiceCorrectParameters.Tests {
param(
  [string] $testDirectory,
  [string] $serviceName = "installServiceTest",
  [string] $createServiceCommand = "nssm install installServiceTest",
  [int] $availablePort
)
  $testServiceBatPath = "$testDirectory\testService.bat"
  $testDirectoryExist = Test-Path $testDirectory 
  $createServiceCommandComplete = "$createServiceCommand `"$testServiceBatPath`""
  
  `cinst NSSM`

  if (!$testDirectoryExist) {
    Write-Host "$testDirectory directory does not exist and will be created"
    New-Item -ItemType Directory -Path $testDirectory
    Set-Content -Value "ping localhost" -Path $testServiceBatPath
  }

  Install-ChocolateyService -packageName "$serviceName" -serviceName "$serviceName"  -createServiceCommand "$createServiceCommandComplete" -availablePort "$availablePort"
}