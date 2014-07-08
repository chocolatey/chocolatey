function Install-ChocolateyService {
param(
  [string] $packageName,
  [string] $serviceName,
  [string] $createServiceCommand,
  [int] $availablePort
)
  Write-Debug "Running 'Install-ChocolateyService' for $packageName with url:`'$url`', unzipLocation: `'$unzipLocation`', url64bit: `'$url64bit`', specificFolder: `'$specificFolder`', checksum: `'$checksum`', checksumType: `'$checksumType`', checksum64: `'$checksum64`', checksumType64: `'$checksumType64`' ";

  if(!$packageName) {
    Write-ChocolateyFailure "Install-ChocolateyService" "Missing PackageName input parameter."
    return
  }  
  
  if(!$serviceName) {
    Write-ChocolateyFailure "Install-ChocolateyService" "Missing ServiceName input parameter."
    return
  }  
 
  if(!$createServiceCommand) {
    Write-ChocolateyFailure "Install-ChocolateyService" "Missing CreateServiceCommand input parameter."
    return
  }  

  try {
    Remove-Service -serviceName "$serviceName"
  
    try {
      Write-Host "$packageName service will be installed"
	  Write-Host $createServiceCommand
      iex $createServiceCommand
    } catch {
      Write-ChocolateyFailure "Install-ChocolateyService" "The createServiceCommand is incorrect: '$_'."
	  return
    }

    if($availablePort) {
      $listeningStatePort = Get-NetTCPConnection -State Listen | Where-Object {$_.LocalAddress -eq "0.0.0.0" -and $_.LocalPort -eq "$availablePort"}
      if (!$listeningStatePort) {
        return $TRUE
      } else {
        Write-ChocolateyFailure "Install-ChocolateyService" "$availablePort is in LISTENING state and not available."
        return
      }
	}	
	
    if (Get-ServiceExistence -serviceName "$serviceName") {
      Write-Host "$packageName service will be started"
	  
	  for ($i=0;$i -lt 12; $i++) {
	    $serviceStatus = Get-Service -Name $serviceName
		
		start-service $serviceName
        
		if ($serviceStatus.Status -eq "running") {
		  Write-Host "$packageName service has been started"
		  return
		}
		Start-Sleep -s 5
      }
    } else {
      Write-ChocolateyFailure "Install-ChocolateyService" "service $serviceName does not exist."
      return
    }	
  } catch {
    Write-ChocolateyFailure "Install-ChocolateyService" "There were errors attempting to create the $packageName service. The error message was '$_'."
  }
}