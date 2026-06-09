function Set-FOMService {
    param($Name, $StartupType)
    try {
        $svc = Get-Service -Name $Name -ErrorAction Stop
        if ($svc.Status -eq "Running" -and $StartupType -eq "Disabled") {
            Stop-Service -Name $Name -Force -ErrorAction SilentlyContinue
        }
        if (($PSVersionTable.PSVersion.Major -lt 7) -and ($StartupType -eq "AutomaticDelayedStart")) {
            sc.exe config $Name start=delayed-auto | Out-Null
        } else {
            Set-Service -Name $Name -StartupType $StartupType -ErrorAction Stop
        }
        Write-FOMLog "  Servizio $Name -> $StartupType" "STEP"
    } catch [System.ServiceProcess.ServiceNotFoundException] {
        Write-FOMLog "  Servizio $Name non trovato" "WARN"
    } catch {
        Write-FOMLog "  Errore servizio $Name`: $_" "ERROR"
    }
}
