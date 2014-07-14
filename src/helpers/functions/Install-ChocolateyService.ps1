function Install-ChocolateyService {
<#
.SYNOPSIS
Installs a service

.DESCRIPTION
This will install a service

.PARAMETER PackageName
The name of the package for whom the service will be installed.

.PARAMETER ServiceName
The name of service which will be used to install and start the service.

.PARAMETER CreateServiceCommand
The command which installs the service.

.PARAMETER AvailablePort (OPTIONAL)
The port which needs to be available in order to start the service.

.EXAMPLE
Install-ChocolateyService 'PACKAGE_NAME' 'SERVICE_NAME' 'INSTALL_COMMAND' 'PORT'
Install-ChocolateyService "dcm4chee" "DCM4CHEE" "nssm install DCM4CHEE `"java`" -jar `"%DCM4CHEE_HOME%/bin/run.jar"`" "8090"
Install-ChocolateyService "postgresqlzip" "PostgreSQL" "pg_ctl register -N `"PostgreSQL`" -U `"LocalSystem`" -w" "5432"
Install-ChocolateyService "apacheds" "ApacheDS" "nssm install ApacheDS `"java`" -jar `"%APACHEDS_HOME%/lib/apacheds-service-${version}.jar`" `"%APACHEDS_HOME%/instances/default`"" "10389"
Install-ChocolateyService "test" "test" "nssm install test `"$testDirectory\testService.bat`""

.OUTPUTS
None

.NOTES
This helper reduces the number of lines one would have to write to install a service to 1 line.
This method has error handling built into it.

.LINK
Uninstall-ChocolateyService
Get-ServiceExistence
#>
param(
  [string] $packageName,
  [string] $serviceName,
  [string] $createServiceCommand,
  [int] $availablePort
)
  Write-Debug "Running 'Install-ChocolateyService' for $packageName with serviceName:`'$serviceName`', createServiceCommand: `'$createServiceCommand`', availablePort: `'$availablePort`' ";

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
    Uninstall-ChocolateyService -serviceName "$serviceName"
  
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