function Install-ChocolateyExplorerMenuItem {
<#
.SYNOPSIS
Creates a windows explorer context menu item that can be associated with a command

.DESCRIPTION
Install-ChocolateyExplorerMenuItem can add an entry in the context menu of 
Windows Explorer. The menu item is given a text label and a command. The command 
can be any command accepted on the windows command line. The menu item can be 
applied to either folder items or file items.

Because this command accesses and edits the root class registry node, it will be 
elevated to admin.

.PARAMETER MenuKey
A unique string to identify this menu item in the registry

.PARAMETER MenuLabel
The string that will be displayed in the context menu

.PARAMETER Command
A command line command that will be invoked when the menu item is selected

.PARAMETER Type
Specifies if the menu item should be applied to a folder or a file

.PARAMETER extension
You probably want to add an Explorer Menu Item for a specific filetype only. Use this to specify

.EXAMPLE
C:\PS>$sublimeDir = (Get-ChildItem $env:systemdrive\chocolatey\lib\sublimetext* | select $_.last)
C:\PS>$sublimeExe = "$sublimeDir\tools\sublime_text.exe"
C:\PS>Install-ChocolateyExplorerMenuItem "sublime" "Open with Sublime Text 2" $sublimeExe

This will create a context menu item in Windows Explorer when any file is right clicked. The menu item will appear with the text "Open with Sublime Text 2" and will invoke sublime text 2 when selected.

.EXAMPLE
C:\PS>$sublimeDir = (Get-ChildItem $env:systemdrive\chocolatey\lib\sublimetext* | select $_.last)
C:\PS>$sublimeExe = "$sublimeDir\tools\sublime_text.exe"
C:\PS>Install-ChocolateyExplorerMenuItem "sublime" "Open with Sublime Text 2" $sublimeExe "directory"

This will create a context menu item in Windows Explorer when any folder is right clicked. The menu item will appear with the text "Open with Sublime Text 2" and will invoke sublime text 2 when selected.

.EXAMPLE
C:\PS> Install-ChocolateyExplorerMenuItem startNotepadPP 'Edit with Notepad++' '\"C:\Program Files (x86)\Notepad++\notepad++.exe\" -with -some -arguments \"%1\"'

This will add a Notepad++ option to the right-click menu of .txt files only. This is just a proof of concept, Notepad++ does this automatically when using the installer.
Remember, if you use quotes in your command, the command must be enclosed in single quotes, and quotes in the command must be escaped. The other way around doesn't work.

.NOTES
Chocolatey will automatically add the path of the file or folder clicked to the command. This is done simply by appending a %1 to the end of the command.
#>
param(
  [string]$menuKey, 
  [string]$menuLabel, 
  [string]$command, 
  [ValidateSet('file','directory')]
  [string]$type = "file",
  [string]$extension
)
try {
  # Verify parameters
  if ($menuKey -eq "" -Or $menuLabel -eq "" -Or $command -eq "") {
    echo "Invalid parameters."
    echo "Usage: Install-ChocolateyExplorerMenuItem MenuKey MenuLabel Command [Type] [Extension]"
	return 1
  } else {
    $debug = "Running 'Install-ChocolateyExplorerMenuItem' with menuKey:'$menuKey', menuLabel:'$menuLabel', command:'$command', type:'$type', extension:'$extension'"
    Write-Debug $debug
    Write-Host $debug
  }
  
  # Switch file or folder
  if($type -eq "file") {$key = "*"} elseif($type -eq "directory") {$key="directory"} else{ return 1}
  
  # Check for optional specific extension
  $extension=$extension.trim()
  if ($extension -ne "") {
    # Add dot
    if (-not($extension.StartsWith("."))) {
      $extension = ".$extension"
    }
	# Windows 7 and 8 hase shell extensions in "SystemFileAssociations". XP and below have this in the root IIRC. Not sure. Who uses <=XP anyway.
	$key = "SystemFileAssociations\$extension"
	# if (XP) $key = $extension # <- not sure, just a reminder to look at this for people who care about <= XP
	Write-Host "Installing $menuLabel context menu item for $extension files..."
  }
  
  # Allow simple commands (add %1) and complex commands (custom %1)
  if (-Not $command.Contains("%1")) {
    # Mind the quotes and escapes! This is passed to a script (this) which is passed to a variable which is passed to a script!
	# Every %1 containing command should be passed to this function in single quotes, with internal quotes as escaped double quotes: 'command -with -some -arguments -if=\"%1\"'
    $command = "$command \`"%1\`""
  }
  
  $elevated = "`
    if( -not (Test-Path -path HKCR:) ) {New-PSDrive -Name HKCR -PSProvider registry -Root Hkey_Classes_Root};`
    if(!(test-path -LiteralPath 'HKCR:\$key')) { new-item -Path 'HKCR:\$key' };`
    if(!(test-path -LiteralPath 'HKCR:\$key\shell')) { new-item -Path 'HKCR:\$key\shell' };`
    if(!(test-path -LiteralPath 'HKCR:\$key\shell\$menuKey')) { new-item -Path 'HKCR:\$key\shell\$menuKey' };`
    Set-ItemProperty -LiteralPath 'HKCR:\$key\shell\$menuKey' -Name '(Default)'  -Value '$menuLabel';`
    if(!(test-path -LiteralPath 'HKCR:\$key\shell\$menuKey\command')) { new-item -Path 'HKCR:\$key\shell\$menuKey\command' };`
    Set-ItemProperty -LiteralPath 'HKCR:\$key\shell\$menuKey\command' -Name '(Default)' -Value '$command';`
    return 0;"

  Start-ChocolateyProcessAsAdmin $elevated
  Write-Host "'$menuKey' Explorer context menu item has been created"
} 
catch {
    $errorMessage = "'$menuKey' Explorer context menu item was not created $($_.Exception.Message)"
    Write-Error $errorMessage
    throw $errorMessage
  }
}