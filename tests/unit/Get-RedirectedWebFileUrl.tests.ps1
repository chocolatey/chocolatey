$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$common = Join-Path (Split-Path -Parent $here)  '_Common.ps1'
$base = Split-Path -parent (Split-Path -Parent $here)

. $common
. "$base\src\helpers\functions\Get-RedirectedWebFileUrl.ps1"
. "$base\src\helpers\functions\Get-WebFile.ps1"

$packageName = "my-package"
$urlCsv = "http://localhost/cache/redirecter.csv"
$urlUnknown = "http://example.org/some/mystery.exe"
$url1 = "http://example.org/stuff-1.2.exe"
$url1Redirected = "http://localhost/cache/stuff-1.2.exe"
$mappingCsv1 = @"
url,redirectedUrl
http://example.org/stuff-1.2.exe,http://localhost/cache/stuff-1.2.exe
"@

Describe "Get-RedirectedWebFileUrl with no mapping setting" {
  $env:ChocolateyWebFileRedirecterCsv = ""
  Context "When url is unknown" {
    Mock Get-UTF8Content

    $returnValue = Get-RedirectedWebFileUrl $packageName $urlUnknown

    It "should not attempt to download the mapping CSV" {
      Assert-MockCalled Get-UTF8Content -Exactly 0
    }
    It "should be returned unchanged" {
      $returnValue | Should Be $urlUnknown
    }
  }
}

Describe "Get-RedirectedWebFileUrl with an example mapping defined" {
  $env:ChocolateyWebFileRedirecterCsv = $urlCsv
  Mock Get-UTF8Content {$mappingCsv1} -Verifiable -ParameterFilter {$location -eq $urlCsv}

  Context "When url is unknown" {
    $returnValue = Get-RedirectedWebFileUrl $packageName $urlUnknown

    It "should attempt to download the mapping CSV" {
      Assert-MockCalled Get-UTF8Content -Exactly 1
    }
    It "should be returned unchanged" {
      $returnValue | Should Be $urlUnknown
    }
  }

  Context "When url is to be redirected" {
    $returnValue = Get-RedirectedWebFileUrl $packageName $url1

    It "should attempt to download the mapping CSV" {
      Assert-MockCalled Get-UTF8Content -Exactly 1
    }
    It "should be returned in the new form" {
      $returnValue | Should Be $url1Redirected
    }
  }
}

Describe "Get-UTF8Content" {
  Context "When url is blank" {
    Mock Get-WebFile {}

    $returnValue = Get-UTF8Content ''
    It "should return null" {
      $returnValue | Should Be $null
    }
  }

  Context "When url is http-like, such as $url1" {
    $myContent = "blah"
    Mock Get-WebFile {$myContent >> $fileName} -Verifiable -ParameterFilter {$url -eq $url1}

    $returnValue = Get-UTF8Content $url1
    It "should return $myContent" {
      Assert-VerifiableMocks
      $returnValue | Should Be $myContent
    }
  }

  Context "When url is path-like" {
    $myContent = "blah2"
    $pathRef = "TestDrive:\dummy\stuff.txt"
    Setup -File 'dummy\stuff.txt' $myContent
  
    $returnValue = Get-UTF8Content $pathRef
    It "should return $myContent" {
      $returnValue | Should Be $myContent
    }
  }

  Context "When url is http-like and wrong" {
    Mock Get-WebFile {throw "not found!"}
    Mock Write-Error
 
    $returnValue = Get-UTF8Content $url1
    It "should warn but return null" {
      Assert-MockCalled Write-Error -Times 1
      $returnValue | Should Be $null
    }
  }

  Context "When url is path-like and wrong" {
    $pathRef = "TestDrive:\dummy\stuff_notexisting.txt"
    Mock Write-Error
  
    $returnValue = Get-UTF8Content $pathRef
    It "should warn but return null" {
      Assert-MockCalled Write-Error -Times 1
      $returnValue | Should Be $null
    }
  }
}

Describe "Join-Location" {
  Context "When both locations are complete http" {
    $returnValue = Join-Location -baseLocation $urlUnknown -relativeLocation $url1
    It "should just return the second" {
      $returnValue | Should Be $url1
    }
  }

  Context "When the first is a http leaf and the second relative" {
    $returnValue = Join-Location -baseLocation "http://example.org/files/blah.csv" -relativeLocation "extradir\something.dat"
    It "should return the merge, dropping the file part of the first" {
      $returnValue | Should Be "http://example.org/files/extradir/something.dat"
    }
  }

  Context "When the first is a http dir and the second relative" {
    $returnValue = Join-Location -baseLocation "http://example.org/download/" -relativeLocation "extradir\something.dat"
    It "should return the merge, dropping the file part of the first" {
      $returnValue | Should Be "http://example.org/download/extradir/something.dat"
    }
  }

  Context "When both locations are complete, only semi-understood file paths" {
    Setup -File 'files\redir.csv' "stuff"
    $returnValue = Join-Location -baseLocation "TestDrive:\files\redir.csv" -relativeLocation "TestDrive:\files\maybe\here.txt"
    It "should return the second" {
      $returnValue | Should Be "TestDrive:\files\maybe\here.txt"
    }
  }

  Context "When the first is a file path and the second relative" {
    $returnValue = Join-Location -baseLocation "c:\blarth\redir.csv" -relativeLocation "over\there.txt"
    It "should return the merged result, as a file Uri" {
      $returnValue | Should Be "file:///c:/blarth/over/there.txt"
    }
  }

  Context "When the first is a UNC dir and the second relative" {
    $returnValue = Join-Location -baseLocation "\\someserver\share\_.csv" -relativeLocation "x\y.dat"
    It "should return the merged result, as a file Uri" {
      $returnValue | Should Be "file://someserver/share/x/y.dat"
    }
  }
}

