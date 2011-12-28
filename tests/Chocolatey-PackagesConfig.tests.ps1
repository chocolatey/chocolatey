$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$src = Join-Path (Split-Path $here) 'src'
$script = Join-Path $src 'chocolatey.ps1'

. $script

function Chocolatey-NuGet {
  param(
    $packageName = '',
    $source = 'https://go.microsoft.com/fwlink/?LinkID=206669',
    $version = ''
  )

  $script:chocolatey_nuget_was_called = $true
  $script:packageName = $packageName
  $script:version = $version
}

function Chocolatey-WebPI {
  $script:chocolatey_webpi_was_called = $true
}

function Chocolatey-RubyGem {
  $script:chocolatey_rubygem_was_called = $true
}

Describe "When installing packages from a manifest that doesn't exist" {

  $script:chocolatey_nuget_was_called = $false
  $script:packageName = ''
  $script:version = ''

  Chocolatey-PackagesConfig "TestDrive:\packages.config"

  It "should do nothing, just like NuGet" {
    $script:chocolatey_nuget_was_called.should.be($false)
  }

}

Describe "When installing packages from a badly formatted manifest" {

  $script:chocolatey_nuget_was_called = $false
  $script:packageName = ''
  $script:version = ''

  Setup -File 'packages.config' @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="chocolateytestpackage" version="0.1" />
</packages>  
"@

  Chocolatey-PackagesConfig "TestDrive:\packages.config"

  It "should I dunno like do something" {
    # depends on the malformation, really
    #  1. element (like `<pakage ... />`)
    #     The xml object for loop will skip it.
    #  2. attribute (like `<package ... verion="0.1" />`)
    #     A null/empty value will be passed on.
  }

}

Describe "When installing packages from a manifest" {

  $script:chocolatey_nuget_was_called = $false
  $script:packageName = ''
  $script:version = ''

  Setup -File 'packages.config' @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="chocolateytestpackage" version="0.1" />
</packages>  
"@
  
  Chocolatey-PackagesConfig "TestDrive:\packages.config"
  
  It "should call chocolatey nuget with each package and version" {
    $script:packageName.should.be('chocolateytestpackage')
    $script:version.should.be('0.1')
  }

}

Describe "When installing packages from a manifest with no versions" {

  $script:chocolatey_nuget_was_called = $false
  $script:packageName = ''
  $script:version = ''

  Setup -File 'packages.config' @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="chocolateytestpackage" />
</packages>  
"@
  
  Chocolatey-PackagesConfig "TestDrive:\packages.config"
  
  It "should call chocolatey nuget without a version specified" {
    $script:packageName.should.be('chocolateytestpackage')
    $true.should.be(($script:version -eq ''))
  }

}

Describe "When installing ruby packages from a manifest" {
  
  $script:chocolatey_rubygem_was_called = $false
  
  Setup -File 'packages.config' @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="chocolateytestpackage" version="0.1" source="ruby" />
</packages>  
"@
  
  Chocolatey-PackagesConfig "TestDrive:\packages.config"
  
  It "should call chocolatey rubygem" {
    $script:chocolatey_rubygem_was_called.should.be($true)
  }

}

Describe "When installing webpi packages from a manifest" {
  
  $script:chocolatey_rubygem_was_called = $false
  
  Setup -File 'packages.config' @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="chocolateytestpackage" source="webpi" />
</packages>  
"@
  
  Chocolatey-PackagesConfig "TestDrive:\packages.config"
  
  It "should call chocolatey webpi" {
    $script:chocolatey_webpi_was_called.should.be($true)
  }

}