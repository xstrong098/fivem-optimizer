function Invoke-FOMRunspace {
    param($ScriptBlock, [array]$ParameterList = @())

    $ps = [powershell]::Create()
    $ps.AddScript($ScriptBlock) | Out-Null
    foreach ($param in $ParameterList) {
        $ps.AddParameter($param[0], $param[1]) | Out-Null
    }
    $ps.RunspacePool = $sync.runspace
    $handle = $ps.BeginInvoke()

    # Poll for completion on UI dispatcher timer so we don't block
    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]::FromMilliseconds(250)
    $capturedPs     = $ps
    $capturedHandle = $handle
    $timer.Add_Tick({
        if ($capturedHandle.IsCompleted) {
            $timer.Stop()
            try   { $capturedPs.EndInvoke($capturedHandle) } catch {}
            $capturedPs.Dispose()
        }
    })
    $timer.Start()

    return $handle
}
