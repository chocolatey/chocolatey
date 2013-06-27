@echo off

set DIR=%~dp0%

REM Handle empty parameter here because in the loop empty means 'end loop goto eof'
if '%1'=='' goto usage

REM Help
if '%1'=='/?' goto usage
if '%1'=='-?' goto usage
if '%1'=='?' goto usage
if '%1'=='/help' goto usage
if '%1'=='help' goto usage
if '%1'=='--help' goto usage

REM Are we not installing (a) package(s)?
if /i not '%1' == 'install' goto single

REM are we not specifying a 3rd parameter?
if '%3' == '' goto single

REM If "-wildcard" is given as third parameter, we are installing a single package.
set param=%3
set param=%param:~0,1%
if '%param%' == '-' goto single

REM If we got no more than 2 parameters, we are installing a single package.
set numArgs=0
for %%n in (%*) do set /A numArgs+=1
if '%numArgs%' LEQ '2' goto single

REM Batch install
echo Installing packages in batch mode.
for %%P in (%*) do (
	REM Installer
	if not '%%P' == 'install' (
		echo.
		echo Installing %%P ...
		echo.
		@PowerShell -NoProfile -ExecutionPolicy unrestricted -Command "[System.Threading.Thread]::CurrentThread.CurrentCulture = ''; [System.Threading.Thread]::CurrentThread.CurrentUICulture = '';& '%DIR%chocolatey.ps1' install %%P"
	)
)
echo.
echo Installed all packages. :)
REM Except for the ones that failed. Need batch-logging. But we need normal logging first. It's in the pipeline @ #154
goto :eof

:single
REM Single command
@PowerShell -NoProfile -ExecutionPolicy unrestricted -Command "[System.Threading.Thread]::CurrentThread.CurrentCulture = ''; [System.Threading.Thread]::CurrentThread.CurrentUICulture = '';& '%DIR%chocolatey.ps1' %*"
goto :eof

:usage
REM Display help
@PowerShell -NoProfile -ExecutionPolicy unrestricted -Command "[System.Threading.Thread]::CurrentThread.CurrentCulture = ''; [System.Threading.Thread]::CurrentThread.CurrentUICulture = '';& '%DIR%chocolatey.ps1' help"
goto :eof
