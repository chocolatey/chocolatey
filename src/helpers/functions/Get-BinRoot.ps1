function Get-BinRoot {
<#
.SYNOPSIS
Gets the path to where binaries should be installed. Either by environmental variable `ChocolateyBinRoot` or by default. E.g. `C:\Tools`

.EXAMPLE
$scriptPath = (Split-Path -parent $MyInvocation.MyCommand.Definition)
Get-ChocolateyUnzip "c:\someFile.zip" $scriptPath somedirinzip\somedirinzip

.OUTPUTS
Returns the binary root. Default should IMO be C:\Chocolatey\Bin or C:\Common\Bin

.NOTES
  # Since CamelCase was decided upon when $env:ChocolateyInstall was first invented, whe should stick to this convention and use $env:ChocolateyBinRoot.
  # I propose:
  #    1) all occurances of $env:chocolatey_bin_root be replaced with $env:ChocolateyBinRoot;
  #    2) Make the new Chocolatey Installer for new users explicitly set (if not exists) $env:ChocolateyInstall and $env:ChocolateyBinRoot as environment variables so users will smile and understand;
  #    3) Make new Chocolatey convert old $env:chocolatey_bin_root to $env:ChocolateyBinRoot
  #    4) If there is no bin root, we default to SystemDrive\tools
#>

  Write-Debug "Running 'Get-BinRoot'";

  $binRoot = ''

  # Do we have a 2014 BinRoot?
  if ($env:ChocolateyBinRoot -eq $null) { # No
	# Do we have a 1995 bin_root?
    if ($env:chocolatey_bin_root -eq $null) { # No
      # Do we have a Chocolatey path?
      if ($env:ChocolateyInstall -eq $null) { # No
        # Okay, I don't know where Chocolatey is installed, so lets make `C:\Tools` the default.
        $env:ChocolateyBinRoot = join-path $env:systemdrive 'tools'
      }
      else { # Use `%ChocolateyInstall%/bin` path as default
        $env:ChocolateyBinRoot = join-path $env:ChocolateyInstall 'bin'
      }
    }
    else { # Use 1995 setting. Warning: This may or may not contain a drive letter!
      $env:ChocolateyBinRoot = $env:chocolatey_bin_root
    }
  }

  # My ChocolateyBinRoot is C:\Common\bin, but looking at other packages, not everyone assumes ChocolateyBinRoot is prepended with a drive letter.
  if (-not($env:ChocolateyBinRoot -imatch "^\w:")) {
    # Add drive letter
    $binRoot = join-path $env:systemdrive $env:ChocolateyBinRoot
  }
  else {
    $binRoot = $env:ChocolateyBinRoot
  }

  # Now that we figured out the binRoot, let's store it as per proposal #3 line #7
  if (-not($env:ChocolateyBinRoot -eq $binRoot)) {
    [Environment]::SetEnvironmentVariable("ChocolateyBinRoot", "$binRoot", "User")
    # Note that user variables pose a problem when there are two admins on one computer. But this is what was decided upon.
  }

  return $binRoot
}
