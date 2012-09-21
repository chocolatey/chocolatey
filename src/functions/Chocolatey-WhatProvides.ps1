function Chocolatey-WhatProvides {
param(
  [string] $fileName=''
)
gci -Path C:\chocolatey\lib\ -Filter *.txt -Recurse | select-string $filename |fw path -Column 1
}