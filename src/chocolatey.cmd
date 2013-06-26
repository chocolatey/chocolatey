@echo off

SET DIR=%~dp0%

REM Handle empty parameter here because in the loop empty means 'end loop goto eof'
if '%1'=='' GOTO usage

REM Help
if '%1'=='/?' goto usage
if '%1'=='-?' goto usage
if '%1'=='?' goto usage
if '%1'=='/help' goto usage
if '%1'=='help' goto usage
if '%1'=='--help' goto usage


set numArgs=0
for %%n in (%*) do Set /A numArgs+=1
if '%numArgs%' GTR '2' echo Installing packages in batch mode.

FOR %%P IN (%*) DO (
	REM Installer
	if not '%%P' == 'install' (
		if '%numArgs%' GTR '2' echo Installing %%P ...
		@PowerShell -NoProfile -ExecutionPolicy unrestricted -Command "[System.Threading.Thread]::CurrentThread.CurrentCulture = ''; [System.Threading.Thread]::CurrentThread.CurrentUICulture = '';& '%DIR%chocolatey.ps1' install %%P"
	)
)
goto :eof

:usage
REM Display help
@PowerShell -NoProfile -ExecutionPolicy unrestricted -Command "[System.Threading.Thread]::CurrentThread.CurrentCulture = ''; [System.Threading.Thread]::CurrentThread.CurrentUICulture = '';& '%DIR%chocolatey.ps1' help"
