function Execute-Process {
param(
  [string] $exe,
  [string] $arguments = '',
  [switch] $returnOutput = $false,
  [switch] $returnErrors = $false,
  [switch] $windowStyleHidden = $false
)
    Write-Debug "Calling `'$exe`' $arguments"
    $global:output = $null;
    $global:errors = $null;

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = New-Object System.Diagnostics.ProcessStartInfo($exe, $arguments)
    $process.StartInfo.UseShellExecute = $false
    if($windowStyleHidden) {
        $process.StartInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
    }

    if ($returnOutput -and (-not $returnErrors)) {
        Write-Debug "Capturing output only"
        $process.StartInfo.RedirectStandardOutput = $true
        $process.Start() | Out-Null
        $global:output = $process.StandardOutput.ReadToEnd()
        $process.WaitForExit()
    } elseif ($returnErrors -and (-not $returnOutput)) {
        Write-Debug "Capturing errors only"
        $process.StartInfo.RedirectStandardError = $true
        $process.Start() | Out-Null
        $global:errors = $process.StandardError.ReadToEnd()
        $process.WaitForExit()
    } elseif ($returnOutput -and $returnErrors) {
        Write-Debug "Capturing both output and errors"
        $global:errors = New-Object System.Collections.ArrayList
        $process.StartInfo.RedirectStandardOutput = $true
        $process.StartInfo.RedirectStandardError = $true

        $dotNetVersion = ([AppDomain]::CurrentDomain.GetAssemblies() | ? { $_.GetName().Name -eq "mscorlib" }).GetName().Version

        if ($dotNetVersion.Major -gt 3) {
            $process.Start() | Out-Null
            $errorReadTask = $process.StandardError.ReadToEndAsync()
            $global:output = $process.StandardOutput.ReadToEnd()
            $process.WaitForExit()
            $global:errors = $errorReadTask.Result
        } elseif ((Get-ChildItem "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP" | Where-Object {$_.PSChildName -eq "v3.5"} | Measure-Object).Count -eq 1) {
            $process.Start() | Out-Null
            $del = [Delegate]::CreateDelegate([Func``1[[System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]]],$process.StandardError,'ReadToEnd')
            $errorReadAsyncResult = $del.BeginInvoke($null, $null)
            $global:output = $process.StandardOutput.ReadToEnd()
            $process.WaitForExit()
            $global:errors = $del.EndInvoke($errorReadAsyncResult)
        } else {
            # Helper function to emit an IL opcode
            function emit($opcode) {
                if ( ! ($op = [System.Reflection.Emit.OpCodes]::($opcode))) {
                    throw "new-method: opcode '$opcode' is undefined"
                }

                if ($args.Length -gt 0) {
                    $ilg.Emit($op, $args[0])
                } else {
                    $ilg.Emit($op)
                }
            }

            $process.EnableRaisingEvents = $true

            $dynMethod = New-Object System.Reflection.Emit.DynamicMethod ('', [void], (@([Collections.ArrayList],[Object],[System.Diagnostics.DataReceivedEventArgs])), [object], $false)
            $ilg = $dynMethod.GetILGenerator()
            emit Ldarg_0
            emit Ldarg_2
            emit Call ([Collections.ArrayList].GetMethod('Add'))
            $dic = New-Object System.Collections.ArrayList
            $del = $dynMethod.CreateDelegate([System.Diagnostics.DataReceivedEventHandler], $dic)

            $process.add_ErrorDataReceived($del)
            $process.Start() | Out-Null
            $process.BeginErrorReadLine()
            $global:output = $process.StandardOutput.ReadToEnd()
            $process.WaitForExit()
            foreach ($ea in $dic) {
                if ($ea.Data -ne $null) {
                    $global:errors.Add($ea.Data) | Out-Null
                }
            }
        }

        if ($global:errors -ne $null) {$global:errors = [string]::Join("",$global:errors)}
    } else {
        Write-Debug "Capturing neither output nor errors"
        $process.Start() | Out-Null
        $process.WaitForExit()
    }

    $exitCode = $process.ExitCode
    $process.Dispose()

    return New-Object PSObject -Property @{
        ExitCode = $exitCode
        Output = $global:output
        Errors = $global:errors }
}
