function Remove-EnvironmentVariable {
param(
  [parameter(mandatory=$true)][string] $sVariableName,
  [System.EnvironmentVariableTarget] $sScope = [System.EnvironmentVariableTarget]::User
)
[Environment]::SetEnvironmentVariable($sVariableName,$null,$sScope)
}