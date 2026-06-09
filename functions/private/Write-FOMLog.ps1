function Write-FOMLog {
    param(
        [string]$Message,
        [ValidateSet("INFO","OK","WARN","ERROR","STEP","TITLE")]
        [string]$Level = "INFO"
    )
    $ts     = Get-Date -Format "HH:mm:ss"
    $prefix = switch ($Level) {
        "OK"    { "[+]" }
        "WARN"  { "[!]" }
        "ERROR" { "[X]" }
        "STEP"  { " >>" }
        "TITLE" { "===" }
        default { "[i]" }
    }
    $line = "$prefix [$ts] $Message"
    Write-Host $line
    if ($sync.ConsoleOutput) {
        try {
            $sync.ConsoleOutput.Dispatcher.Invoke([action]{
                $sync.ConsoleOutput.AppendText("$line`n")
                $sync.ConsoleOutput.ScrollToEnd()
            }, [System.Windows.Threading.DispatcherPriority]::Background)
        } catch {}
    }
}
