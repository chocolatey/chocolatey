function Get-RedirectedWebFileUrl {
<#
.SYNOPSIS
Switches URL for a local or other equivalent

.DESCRIPTION
Allow switching URLs in packages for locally-controlled equivalents.
This enables packages to work without other adjustment without direct Internet access, and manual caching.

.PARAMETER packageName
The name of the package we want to download - this is arbitrary, call it whatever you want.
It's recommended you call it the same as your nuget package id.

.PARAMETER url
This is the url to be mapped.

.EXAMPLE
Get-RedirectedWebFileUrl 'mycoolapp' 'http://www.coolco.com/download?app=coolapp.exe&ver=3.21'

.NOTES
Uses the environment variable 'ChocolateyWebFileRedirecterCsv' as a source for the mapping CSV
returns with the redirected url in the newUrl property of a PSObject, or $null if no mapping

.LINK
Get-ChocolateyWebFile
Get-UTF8Content
#>
param(
  [string] $packageName,
  [string] $url
)
  Write-Debug "Running 'Get-RedirectedWebFileUrl' for $packageName and $url";

  $redirecterCsvLocation = $env:ChocolateyWebFileRedirecterCsv
  if (! $redirecterCsvLocation) {
    Write-Debug "No ChocolateyWebFileRedirecterCsv environment variable - skipping WebFile redirection"
  } else {
    $redirecterCsvRaw = Get-UTF8Content($redirecterCsvLocation)
    if (! $redirecterCsvRaw) {
      throw "Skipping WebFile Url mapping as error accessing $redirecterCsvLocation"
    } else {
      $redirecterCsv = @($redirecterCsvRaw | ConvertFrom-Csv)
      $mapping = $redirecterCsv | Where-Object { $_.url -eq $url}
      if (! $mapping) {
        Write-Host "Url not found in WebFile Redirecter CSV: $url"
        $uri = $url -as [System.URI]
        if ($uri) {
          $segs = $uri.Segments
          if ($segs.Length -gt 1) {
            $finalSegment = $segs[$segs.Length - 1]
            $possibleOffset = "$packageName\$finalSegment"
            $clash = $redirecterCsv | Where-Object { $_.redirectedUrl -eq $possibleOffset}
            if ($clash) {
              Write-Host "Similar redirected url $($clash.url) to $($clash.redirectedUrl)"
            } else {
              Write-Host "Suggested CSV content (after downloading content to there):"
              Write-Host "url,redirectedUrl"
              Write-Host "`"$url`",`"$possibleOffset`""
            }
          }
        }
      } else {
        $maybePartialRedirectedUrl = $mapping.redirectedUrl
        $redirectedUrl = Join-Location -baseLocation $redirecterCsvLocation -relativeLocation $maybePartialRedirectedUrl
        if (! $redirectedUrl) {
          throw "Could not join $redirecterCsvLocation and $maybePartialRedirectedUrl"
        } else {
          Write-Debug "Redirecting to $redirectedUrl"
          return New-Object -TypeName PSObject -Property @{newUrl=$redirectedUrl}
        }
      }
    }
  }
  
  return $null
}

function Get-UTF8Content {
<#
.SYNOPSIS
Gets content as a string from a remote (http/https) or local source (file url or direct file path)

.PARAMETER location
This is the url or file path to be read.

.NOTES
Assumes the content is in UTF8 format already - make it so!

.LINK
Get-RedirectedWebFileUrl
#>
param(
  [string] $location
)
  if ($location) {
    $localTempFile = $null
    $filename = $null
    try {
      if ($location.StartsWith('http')) {
        $localTempFile = [System.IO.Path]::GetTempFileName()
        Write-Debug "Fetching $location to temporary $localTempFile"
        Get-WebFile -url $location -fileName $localTempFile -quiet
        $filename = $localTempFile
      } elseIf ($location.StartsWith('file')) {
        $filename = ([uri] $location).LocalPath
      } elseIf (Test-Path $location -PathType Leaf) {
        $filename = $location
      } else {
        Write-Error "Missing or could not understand as http/file/path reference: $location"
      }

      if ($filename) {
        return Get-Content $filename -Encoding UTF8
      }
    } catch {
      Write-Error "Error retrieving content of $location, $_" 
    } finally {
      if ($localTempFile) {
        Remove-Item $localTempFile
      }
    }
  }
  
  return $null
}

function Join-Location {
<#
.SYNOPSIS
Joins a potentially relative uri or filepath onto a base
#>
param(
  [string] $baseLocation,
  [string] $relativeLocation
)
  $baseUri = $baseLocation -as [System.URI]
  if ($baseUri) {
    $fullUri = new-object System.Uri ($baseUri, $relativeLocation)
    if ($fullUri) {
      return [string]$fullUri
    }
    throw "Could not join Uri $baseLocation to $relativeLocation"
  }

  return Join-Path (Split-Path -Parent $baseLocation) $relativeLocation
}