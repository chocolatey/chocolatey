function Chocolatey-Sources {
param(
  [string] $operation='', 
  [string] $name='' , 
  [string] $source='' 
)

    switch($operation)
    {
        "list" {
                (Get-ConfigValue "sources").source | format-table @{Expression={$_.id};Label="ID";width=25},@{Expression={$_.value};Label="URI"}
            }
            
        "add" {
                $globalConfigFile = Join-Path $nugetChocolateyPath chocolatey.config
                $globalConfig = [xml] (Get-Content $globalConfigFile)
                
                $newSource = $globalConfig.selectSingleNode("//source[@id='$name']")
                if (-not $newSource){
                    
                    $newSource = $globalConfig.CreateElement("source")
                    
                    $idAttr = $globalConfig.CreateAttribute("id")
                    $idAttr.Value = $name
                    $newSource.SetAttributeNode($idAttr) | Out-Null
                    
                    $valueAttr = $globalConfig.CreateAttribute("value")
                    $valueAttr.Value = $source
                    $newSource.SetAttributeNode($valueAttr) | Out-Null
                    
                    $globalConfig.chocolatey.sources.AppendChild($newSource) | Out-Null
                    $globalConfig.Save($globalConfigFile)
                    
                    Write-Host "Source $name added."
                }
                else {
                    Write-Host "Source $name already exists"
                }
            }
            
        "remove" {
                $globalConfigFile = Join-Path $nugetChocolateyPath chocolatey.config
                $globalConfig = [xml] (Get-Content $globalConfigFile)
                
                $newSource = $globalConfig.selectSingleNode("//source[@id='$name']")
                if ($newSource){                    
                    
                    $globalConfig.chocolatey.sources.RemoveChild($newSource) | Out-Null
                    $globalConfig.Save($globalConfigFile)
                    
                    Write-Host "Source $name removed."
                }
                else {
                    Write-Host "Source $name does not exist"
                }
            }
            
        default { Write-Host "Unrecognized sources operation '$operation'"}
    }
}