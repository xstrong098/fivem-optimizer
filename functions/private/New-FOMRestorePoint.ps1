function New-FOMRestorePoint {
    try {
        Write-FOMLog "Creazione punto di ripristino di sistema..." "INFO"
        $vss = Get-Service -Name VSS -ErrorAction SilentlyContinue
        if ($vss -and $vss.Status -ne 'Running') {
            Start-Service -Name VSS -ErrorAction SilentlyContinue
        }
        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description "FiveM Optimizer v3.0 - $(Get-Date -Format 'yyyy-MM-dd HH:mm')" `
            -RestorePointType MODIFY_SETTINGS -ErrorAction Stop
        Write-FOMLog "Punto di ripristino creato" "OK"
    } catch {
        Write-FOMLog "Punto di ripristino non creato (normale se gia' creato nelle ultime 24h): $($_.Exception.Message)" "WARN"
    }
}
