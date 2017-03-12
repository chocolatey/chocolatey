## Get-WebFile-Simple (aka wget for PowerShell)
##############################################################################################################
## Downloads a file or page from the web
## History:
##############################################################################################################
function Get-WebFileSimple {
param(
  $url = '', #(Read-Host "The URL to download"),
  $fileName = $null,
  $cookies = '',
  [switch]$ignoreInvalidCert
)
  Write-Host "Running 'Get-WebFile' for $fileName with url:`'$url`', cookies: `'$cookies`'";
  
  if($ignoreInvalidCert -eq $true)
  {
    $origCertCheck = [System.Net.ServicePointManager]::ServerCertificateValidationCallback
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
  }
  
  $webclient = new-object System.Net.WebClient
  if($cookies -ne '')
  {
    $webclient.Headers.Add("Cookie",$cookies);
  }
  $webclient.DownloadFile($url, $fileName);
  
  if($ignoreInvalidCert -eq $true)
  {
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = $origCertCheck
  }
}
