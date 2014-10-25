function Remove-Folder {
param(
  [parameter(mandatory=$true)][string] $sFolderPath
)
if(Test-Path -path $sFolderPath ){
  Remove-Item $sFolderPath -recurse
}
}