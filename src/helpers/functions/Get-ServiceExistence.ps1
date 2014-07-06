function Get-ServiceExistence {
param(
  [string] $serviceName = ''
)
  Get-WmiObject -Class Win32_Service -Filter "Name='$serviceName'"
}