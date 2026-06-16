function Set-FOMProgress {
    param([int]$Value, [string]$Status = "")
    if ($sync.MainProgressBar) {
        try {
            $sync.MainProgressBar.Dispatcher.Invoke([action]{
                $sync.MainProgressBar.Value = $Value
            }, [System.Windows.Threading.DispatcherPriority]::Background)
        } catch {}
    }
    if ($sync.StatusBarText -and $Status) {
        try {
            $sync.StatusBarText.Dispatcher.Invoke([action]{
                $sync.StatusBarText.Text = $Status
            }, [System.Windows.Threading.DispatcherPriority]::Background)
        } catch {}
    }
}

function Set-FOMHeaderStatus {
    param([string]$Text, [string]$Color = "#00E676")
    if ($sync.HeaderStatus) {
        try {
            $sync.HeaderStatus.Dispatcher.Invoke([action]{
                $sync.HeaderStatus.Text = "* $Text"
                $sync.HeaderStatus.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString($Color)
            }, [System.Windows.Threading.DispatcherPriority]::Background)
        } catch {}
    }
}
