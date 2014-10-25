function Get-WebHeaders {
param(
  $url = '',
  $userAgent = 'chocolatey command line'
)
  Write-Debug "Running 'Get-WebHeaders' with url:`'$url`', userAgent: `'$userAgent`'";
  if ($url -eq '') { return }

  $request = [System.Net.HttpWebRequest]::Create($url);
  #$request.Method = "HEAD"
  # check if a proxy is required
  $client = New-Object System.Net.WebClient
  if (!$client.Proxy.IsBypassed($url))
  {
    $creds = [Net.CredentialCache]::DefaultCredentials
    if ($creds -eq $null) {
      Write-Debug "Default credentials were null. Attempting backup method"
      $cred = Get-Credential
      $creds = $cred.GetNetworkCredential();
    }
    $proxyAddress = $client.Proxy.GetProxy($url).Authority
    Write-Host "Using this proxyserver: $proxyAddress"
    $proxy = New-Object System.Net.WebProxy($proxyAddress)
    $proxy.credentials = $creds
    $request.proxy = $proxy
  }
  
  # quick fix-up for embedded credentials in the URL
  $bCredentialsExist = $url -match "(?://)(\w+):(\w+)(?:@)"
  if ($bCredentialsExist) {  
    $request.Credentials = New-Object System.Net.NetworkCredential($matches[1],$matches[2])
  }

  $request.Accept = '*/*'
  $request.AllowAutoRedirect = $true
  $request.MaximumAutomaticRedirections = 20
  #$request.KeepAlive = $true
  $request.Timeout = 20000

  #http://stackoverflow.com/questions/518181/too-many-automatic-redirections-were-attempted-error-message-when-using-a-httpw
  $request.CookieContainer = New-Object System.Net.CookieContainer
  if ($userAgent -ne $null) {
    Write-Debug "Setting the UserAgent to `'$userAgent`'"
    $request.UserAgent = $userAgent
  }

  Write-Debug "Request Headers:"
  foreach ($key in $request.Headers) {
    $value = $request.Headers[$key];
    if ($value) {
      Write-Debug "  `'$key`':`'$value`'"
    } else {
      Write-Debug "  `'$key`'"
    }
  }

  $headers = @{}

  try {
    $response = $request.GetResponse();
    Write-Debug "Response Headers:"
    foreach ($key in $response.Headers) {
      $value = $response.Headers[$key];
      if ($value) {
        $headers.Add("$key","$value")
        Write-Debug "  `'$key`':`'$value`'"
      }
    }
    $response.Close();
  }
  catch {
    $request.ServicePoint.MaxIdleTime = 0
    $request.Abort();
    # ruthlessly remove $request to ensure it isn't reused
    Remove-Variable request
    Start-Sleep 1
    [GC]::Collect()
    throw
  }

  $headers
}
