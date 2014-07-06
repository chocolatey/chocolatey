function Get-ServiceStatus {
param(
  [string] $correctServiceName = ''
)
  $serviceStatus = Get-Service -Name $correctServiceName
  $serviceStatus.Status
}