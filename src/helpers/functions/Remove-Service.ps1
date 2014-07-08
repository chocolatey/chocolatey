function Remove-Service {
param(
  [string] $serviceName = ''
)
  if (Get-ServiceExistence -serviceName "$serviceName") {
    Write-Host "$serviceName service already exists and will be removed"
    stop-service $serviceName
    $service = Get-ServiceExistence -serviceName "$serviceName"
    $service.delete()      
  }
}