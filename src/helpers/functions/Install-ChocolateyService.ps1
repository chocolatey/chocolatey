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

.PARAMETER AvailablePort
The port which needs to be available in order to start the service.

.EXAMPLE
Install-ChocolateyService 'PACKAGE_NAME' 'SERVICE_NAME' 'INSTALL_COMMAND' 'PORT'

.OUTPUTS
None

.NOTES
This helper reduces the number of lines one would have to write to install a service to 1 line.
This method has error handling built into it.

.LINK
Get-ChocolateyWebFile
Get-ChocolateyUnzip
#>
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
  
  if(!$availablePort) {
    Write-ChocolateyFailure "Install-ChocolateyService" "Missing AvailablePort input parameter."
    return
  }    

  function installService() {
    if (serviceExists) {
      Write-Host "$packageName service will be installed"
	  
      & $createServiceCommand install $serviceName
	  
	  
    } else {
      Write-ChocolateyFailure 'Install-ChocolateyService' "service $serviceName cannot be installed"
      throw
    }
  }

  function startService() {
#    if (portAvailable) {
#      Write-Host "$packageName service will be started"
	  $service6 = Get-WmiObject -Class Win32_Service -Filter "Name='$serviceName'"
  if ($service6 -match "$serviceName") {
        #start-service $serviceName
  } else {
    Write-ChocolateyFailure "Install-ChocolateyService" "service $serviceName does not exist."
    return
  }
 #   } else {
  #    Write-ChocolateyFailure 'Install-ChocolateyService' "service $serviceName cannot be started"
   #   throw
    #}
  }

  function portAvailable() {
    Try {
      $connection = (New-Object Net.Sockets.TcpClient)
      $connection.Connect("127.0.0.1",$port)
      return $FALSE
    } Catch {
      return $TRUE
    }
  }

  function serviceExists() {
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($service.Length -gt 0) {
      Write-Host "$serviceName service already exists and will be removed"
      stop-service $serviceName
      $service = Get-WmiObject -Class Win32_Service -Filter "Name='$serviceName'"
      $service.delete()
      return $TRUE
    } else {
      return $TRUE
    }
  }  

 # installService

  startService
  
}