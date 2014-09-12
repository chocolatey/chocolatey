function Chocolatey-Sources {
param(
  [string] $operation='',
  [string] $name='' ,
  [string] $source='',
  [string] $type=''
)

  if ($operation -eq $null -or $operation -eq '') {$operation = 'list'}

  Write-Debug "Running 'Chocolatey-Sources' operation `'$operation`' with source name:`'$name`', source location:`'$source`', and type: `'$type`'";

  switch($operation)
  {
    "list" { Get-Sources | format-table @{Expression={$_.id};Label="ID";width=25},@{Expression={$_.type};Label="Type (optional)";width=25},@{Expression={$_.value};Label="URI"}} 

    "add" {
      if ($name -eq '' -or $name -eq $null -or $source -eq '' -or $source -eq $null ) { throw "Please provide -name NameOfSource -source LocationOfSource"}

      Write-UserConfig { param($userConfig)
        $newSource = $userConfig.selectSingleNode("//source[@id='$name']")
        if (-not $newSource){
          $newSource = $userConfig.CreateElement("source")

          $idAttr = $userConfig.CreateAttribute("id")
          $idAttr.Value = $name
          $newSource.SetAttributeNode($idAttr) | Out-Null

          $valueAttr = $userConfig.CreateAttribute("value")
          $valueAttr.Value = $source
          $newSource.SetAttributeNode($valueAttr) | Out-Null
		  
		  if ($type -ne '' -and $type -ne $null) {
		    $typeAttr = $userConfig.CreateAttribute("type")
		    $typeAttr.Value = $type
		    $newSource.SetAttributeNode($typeAttr) | Out-Null
		  }

          $sources = $userConfig.selectSingleNode("//sources")
          $sources.AppendChild($newSource) | Out-Null

          Write-Host "Source $name added."
          $true
        } else {
          Write-Host "Source $name already exists"
        }
      }
    }

    "remove" {
      if ($name -eq '' -or $name -eq $null) { throw "Please provide -name NameOfSource"}

      Write-UserConfig { param($userConfig)
        $source = $userConfig.selectSingleNode("//source[@id='$name']")
        if ($source){
          $sources = $userConfig.selectSingleNode("//sources")
          $sources.RemoveChild($source) | Out-Null

		  # utilize a helper to remove the cache for this repository as well
		  Remove-Cache $source
		  		  
          Write-Host "Source $name removed."
          $true
        } else {
          Write-Host "Source $name does not exist or is a global which can't be removed (use disable if this is the case)."
        }
      }
    }

    "enable" {
      if ($name -eq '' -or $name -eq $null) { throw "Please provide -name NameOfSource"}

      Write-UserConfig { param($userConfig)
        $disabledNode = $userConfig.selectSingleNode("//disabled[@id='$name']")
        if ($disabledNode){
          $sources = $userConfig.selectSingleNode("//sources")
          $sources.RemoveChild($disabledNode) | Out-Null

          Write-Host "Source $name enabled."
          $true
        } else {
          Write-Host "Source $name already enabled"
        }
      }
    }

    "disable" {
      if ($name -eq '' -or $name -eq $null) { throw "Please provide -name NameOfSource"}

      Write-UserConfig { param($userConfig)
        $disabledNode = $userConfig.selectSingleNode("//disabled[@id='$name']")
        if (-not $disabledNode){
          $disabledNode = $userConfig.CreateElement("disabled")

          $idAttr = $userConfig.CreateAttribute("id")
          $idAttr.Value = $name
          $disabledNode.SetAttributeNode($idAttr) | Out-Null

          $sources = $userConfig.selectSingleNode("//sources")
          $sources.AppendChild($disabledNode) | Out-Null

          Write-Host "Source $name disabled."
          $true
        } else {
          Write-Host "Source $name already disabled"
        }
      }
    }
	
	"update" { 
		$sources = Get-Sources

		$sources | foreach {
			Update-Cache $_
		}
		
		Write-Host "Sources updated."
	}

    default { throw "Unrecognized sources operation '$operation'"}

  }
}

