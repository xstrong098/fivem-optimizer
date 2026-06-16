function Invoke-FOMTweaksButton {
    param([bool]$Undo = $false)

    if ($sync.ProcessRunning) {
        [System.Windows.MessageBox]::Show(
            "Un'operazione e' gia' in corso. Attendi il completamento.",
            "FiveM Optimizer", "OK", "Warning") | Out-Null
        return
    }

    # Collect all checked tweak IDs
    $selected = [System.Collections.Generic.List[string]]::new()
    foreach ($key in @($sync.Keys)) {
        if ($key -match '^ck_' -and $sync[$key] -is [System.Windows.Controls.CheckBox] -and $sync[$key].IsChecked) {
            $selected.Add(($key -replace '^ck_', ''))
        }
    }

    if ($selected.Count -eq 0) {
        [System.Windows.MessageBox]::Show(
            "Seleziona almeno un tweak da applicare.",
            "FiveM Optimizer", "OK", "Warning") | Out-Null
        return
    }

    $verb = if ($Undo) { "UNDO" } else { "RUN TWEAKS" }
    Set-FOMHeaderStatus "$verb in corso..." "#FFAB40"
    Set-FOMProgress -Value 0 -Status "$verb avviato..."

    Invoke-FOMRunspace -ParameterList @(("tweaks", $selected), ("undo", $Undo)) -ScriptBlock {
        param($tweaks, $undo)
        $sync.ProcessRunning = $true
        $total = $tweaks.Count
        $i     = 0
        Write-FOMLog "$( if ($undo) { 'UNDO' } else { 'RUN TWEAKS' } ) - $total tweaks selezionati" "TITLE"
        if (-not $undo) {
            New-FOMRestorePoint
        }
        foreach ($id in $tweaks) {
            $i++
            $pct = [int](($i / $total) * 100)
            Set-FOMProgress -Value $pct -Status "$( if ($undo) { 'Undo' } else { 'Applico' } ): $id ($i/$total)"
            Invoke-FOMTweaks -TweakID $id -Undo $undo
        }
        Set-FOMProgress -Value 100 -Status "Completato - $total tweaks"
        Write-FOMLog "========================================" "INFO"
        Write-FOMLog "Operazione completata. $total tweaks processati." "OK"
        Write-FOMLog "Alcuni tweaks richiedono il riavvio del PC." "WARN"
        Set-FOMHeaderStatus "Completato" "#00E676"
        $sync.ProcessRunning = $false
    }
}
