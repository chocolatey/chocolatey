function Invoke-ChocolateyFunction ($ChocoFunction,$paramlist) {
  try {
    $paramstr = ''
    $formatter = { param($x) if ($x -is [string]) { "'$($x)'" } else { if ($x -eq $null) { '$null' } else { $x } } }
    if ($paramlist -is [array]) {
      $paramstr = '(' + (($paramlist | % { & $formatter $_ }) -join ',') + ')'
    } else {
      if ($paramlist -is [hashtable]) {
        # note: no way to distinguish between [switch] and [bool] parameters without reflecting on $ChocoFunction;
        # string displayed for switches will be syntactically incorrect, but will show correct value, e.g. '-uninstall True'
        $paramstr = ($paramlist.GetEnumerator() | % { '-' + $_.Name + ' ' + (& $formatter $_.Value) }) -join ' '
      } else {
        $paramstr = "'$paramlist'"
      }
    }
    Write-Debug "Invoke-ChocolateyFunction is calling: `$ChocoFunction='$ChocoFunction'|`@paramlist=$paramstr"
    invoke-expression "$ChocoFunction @paramlist;"
  }
  #catch {Write-Host $_.exception.message -BackgroundColor Red -ForegroundColor White ;exit 1}
  catch {
    Write-Debug "Caught `'$_`'"
    throw "$($_.Exception.Message)"
  }
}
