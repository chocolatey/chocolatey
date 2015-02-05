function Get-ServiceStatus {
param(
  [string] $serviceName = ''
)
  $serviceStatus = Get-Service -Name $serviceName
  $serviceStatus.Status
}