function Write-Folder {
param(
  [parameter(mandatory=$true)][string] $sFolderPath
)
if( -Not ( Test-Path -path $sFolderPath )){
  New-Item -path $sFolderPath -type directory -force
}
}