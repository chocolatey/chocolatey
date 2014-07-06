function getServiceExistence {
param(
  [string] $correctServiceName = ''
)
  Get-WmiObject -Class Win32_Service -Filter "Name='$correctServiceName'"
}