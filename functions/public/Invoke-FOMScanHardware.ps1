# ── Scanner panel UI (chiamata da Invoke-FOMBuildUI) ──────────────────────────
function New-FOMScannerPanel {
    $conv = [System.Windows.Media.BrushConverter]::new()

    $sp = New-Object System.Windows.Controls.StackPanel
    $sp.Margin = [System.Windows.Thickness]::new(0,2,0,0)

    # ── Header ─────────────────────────────────────────────────────────────────
    $hdr = New-Object System.Windows.Controls.Border
    $hdr.Background      = $conv.ConvertFromString("#0B1929")
    $hdr.BorderBrush     = $conv.ConvertFromString("#00C8FF")
    $hdr.BorderThickness = [System.Windows.Thickness]::new(0,0,0,2)
    $hdr.CornerRadius    = [System.Windows.CornerRadius]::new(6,6,0,0)
    $hdr.Padding         = [System.Windows.Thickness]::new(14,12,14,12)
    $hdr.Margin          = [System.Windows.Thickness]::new(0,0,0,10)

    $hdrSP = New-Object System.Windows.Controls.StackPanel
    $t1 = New-Object System.Windows.Controls.TextBlock
    $t1.Text       = "HARDWARE SCANNER"
    $t1.FontSize   = 15
    $t1.FontWeight = [System.Windows.FontWeights]::Bold
    $t1.Foreground = $conv.ConvertFromString("#00C8FF")
    $t1.Margin     = [System.Windows.Thickness]::new(0,0,0,5)
    $t2 = New-Object System.Windows.Controls.TextBlock
    $t2.Text        = "Analizza CPU, GPU, RAM, disco e software installato. Seleziona automaticamente i tweaks piu adatti alla tua configurazione."
    $t2.FontSize    = 11
    $t2.Foreground  = $conv.ConvertFromString("#5A6A8A")
    $t2.TextWrapping = [System.Windows.TextWrapping]::Wrap
    $hdrSP.Children.Add($t1) | Out-Null
    $hdrSP.Children.Add($t2) | Out-Null
    $hdr.Child = $hdrSP
    $sp.Children.Add($hdr) | Out-Null

    # ── Scan button ─────────────────────────────────────────────────────────────
    $btn = New-Object System.Windows.Controls.Button
    $btn.Content         = "⚡   SCANSIONA IL PC"
    $btn.Height          = 44
    $btn.Margin          = [System.Windows.Thickness]::new(0,0,0,10)
    $btn.FontSize        = 13
    $btn.FontWeight      = [System.Windows.FontWeights]::Bold
    $btn.Cursor          = [System.Windows.Input.Cursors]::Hand
    $btn.Background      = $conv.ConvertFromString("#0D2535")
    $btn.Foreground      = $conv.ConvertFromString("#00C8FF")
    $btn.BorderBrush     = $conv.ConvertFromString("#00C8FF")
    $btn.BorderThickness = [System.Windows.Thickness]::new(1)
    try { $btn.Style = $sync.Form.FindResource("BtnCyan") } catch {}
    $sp.Children.Add($btn) | Out-Null
    $sync.BtnScanHardware = $btn

    # ── Helper: crea una riga label+valore con Grid a 2 colonne ─────────────────
    function New-ScanRow {
        param([string]$Label, [string]$SyncKey)
        $g  = New-Object System.Windows.Controls.Grid
        $g.Margin = [System.Windows.Thickness]::new(0,0,0,6)
        $c0 = New-Object System.Windows.Controls.ColumnDefinition; $c0.Width = [System.Windows.GridLength]::new(72)
        $c1 = New-Object System.Windows.Controls.ColumnDefinition; $c1.Width = [System.Windows.GridLength]::new(1,[System.Windows.GridUnitType]::Star)
        $g.ColumnDefinitions.Add($c0) | Out-Null
        $g.ColumnDefinitions.Add($c1) | Out-Null

        $lbl = New-Object System.Windows.Controls.TextBlock
        $lbl.Text       = $Label
        $lbl.FontSize   = 11
        $lbl.FontWeight = [System.Windows.FontWeights]::SemiBold
        $lbl.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#5A6A8A")
        $lbl.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
        [System.Windows.Controls.Grid]::SetColumn($lbl, 0)

        $val = New-Object System.Windows.Controls.TextBlock
        $val.Text        = "-"
        $val.FontSize    = 11
        $val.Foreground  = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#C0CDE8")
        $val.TextWrapping = [System.Windows.TextWrapping]::Wrap
        [System.Windows.Controls.Grid]::SetColumn($val, 1)

        $g.Children.Add($lbl) | Out-Null
        $g.Children.Add($val) | Out-Null
        $sync[$SyncKey] = $val
        return $g
    }

    # ── Hardware card ───────────────────────────────────────────────────────────
    $hwCard = New-Object System.Windows.Controls.Border
    $hwCard.Background      = $conv.ConvertFromString("#1C2333")
    $hwCard.BorderBrush     = $conv.ConvertFromString("#252D42")
    $hwCard.BorderThickness = [System.Windows.Thickness]::new(1)
    $hwCard.CornerRadius    = [System.Windows.CornerRadius]::new(5)
    $hwCard.Padding         = [System.Windows.Thickness]::new(14,10,14,10)
    $hwCard.Margin          = [System.Windows.Thickness]::new(0,0,0,8)

    $hwSP = New-Object System.Windows.Controls.StackPanel
    $hwLbl = New-Object System.Windows.Controls.TextBlock
    $hwLbl.Text       = "HARDWARE RILEVATO"
    $hwLbl.FontSize   = 10
    $hwLbl.FontWeight = [System.Windows.FontWeights]::SemiBold
    $hwLbl.Foreground = $conv.ConvertFromString("#3A4A6A")
    $hwLbl.Margin     = [System.Windows.Thickness]::new(0,0,0,8)
    $hwSP.Children.Add($hwLbl) | Out-Null
    $hwSP.Children.Add((New-ScanRow "CPU"   "TbHwCpu"))  | Out-Null
    $hwSP.Children.Add((New-ScanRow "GPU"   "TbHwGpu"))  | Out-Null
    $hwSP.Children.Add((New-ScanRow "RAM"   "TbHwRam"))  | Out-Null
    $hwSP.Children.Add((New-ScanRow "Disco" "TbHwDisk")) | Out-Null
    $hwCard.Child = $hwSP
    $sp.Children.Add($hwCard) | Out-Null

    # ── Software card ───────────────────────────────────────────────────────────
    $swCard = New-Object System.Windows.Controls.Border
    $swCard.Background      = $conv.ConvertFromString("#1C2333")
    $swCard.BorderBrush     = $conv.ConvertFromString("#252D42")
    $swCard.BorderThickness = [System.Windows.Thickness]::new(1)
    $swCard.CornerRadius    = [System.Windows.CornerRadius]::new(5)
    $swCard.Padding         = [System.Windows.Thickness]::new(14,10,14,10)
    $swCard.Margin          = [System.Windows.Thickness]::new(0,0,0,8)

    $swSP = New-Object System.Windows.Controls.StackPanel
    $swLbl = New-Object System.Windows.Controls.TextBlock
    $swLbl.Text       = "SOFTWARE RILEVATO"
    $swLbl.FontSize   = 10
    $swLbl.FontWeight = [System.Windows.FontWeights]::SemiBold
    $swLbl.Foreground = $conv.ConvertFromString("#3A4A6A")
    $swLbl.Margin     = [System.Windows.Thickness]::new(0,0,0,8)
    $swSP.Children.Add($swLbl) | Out-Null
    $swSP.Children.Add((New-ScanRow "App"         "TbHwApps"))        | Out-Null
    $swSP.Children.Add((New-ScanRow "Periferiche" "TbHwPeripherals")) | Out-Null
    $swCard.Child = $swSP
    $sp.Children.Add($swCard) | Out-Null

    # ── Status text ─────────────────────────────────────────────────────────────
    $statusTb = New-Object System.Windows.Controls.TextBlock
    $statusTb.Text         = "Premi 'Scansiona il PC' per analizzare la configurazione."
    $statusTb.FontSize     = 11
    $statusTb.Foreground   = $conv.ConvertFromString("#5A6A8A")
    $statusTb.TextWrapping = [System.Windows.TextWrapping]::Wrap
    $statusTb.Margin       = [System.Windows.Thickness]::new(2,0,0,0)
    $sp.Children.Add($statusTb) | Out-Null
    $sync.TbScanStatus = $statusTb

    # Wiring
    $btn.Add_Click({ Invoke-FOMScanHardware })

    return $sp
}

# ── Hardware scanner (eseguito in runspace) ────────────────────────────────────
function Invoke-FOMScanHardware {
    if ($sync.ProcessRunning) {
        [System.Windows.MessageBox]::Show(
            "Un'operazione e' gia' in corso. Attendi il completamento.",
            "FiveM Optimizer", "OK", "Warning") | Out-Null
        return
    }

    # Disabilita bottone e mostra status sulla UI thread
    if ($sync.BtnScanHardware) { $sync.BtnScanHardware.IsEnabled = $false }
    if ($sync.TbScanStatus) {
        $sync.TbScanStatus.Text = "Scansione in corso..."
        $sync.TbScanStatus.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#FFAB40")
    }

    Invoke-FOMRunspace -ParameterList @() -ScriptBlock {

        $sync.ProcessRunning = $true
        Write-FOMLog "═══════════════════════════════════════════" "INFO"
        Write-FOMLog "HARDWARE SCAN - avvio" "TITLE"
        Set-FOMProgress -Value 5 -Status "Rilevamento hardware..."

        # ── CPU ──────────────────────────────────────────────────────────────────
        $cpu     = Get-CimInstance Win32_Processor -EA SilentlyContinue | Select-Object -First 1
        $cpuName = if ($cpu) { ($cpu.Name -replace '\s+',' ').Trim() } else { "Sconosciuto" }
        $isIntel = $cpuName -match 'Intel'
        $isAMD   = $cpuName -match 'AMD'
        Write-FOMLog "CPU: $cpuName" "INFO"
        Set-FOMProgress -Value 15 -Status "CPU rilevata..."

        # ── GPU ──────────────────────────────────────────────────────────────────
        $gpus = @(Get-CimInstance Win32_VideoController -EA SilentlyContinue |
                  Where-Object { $_.Caption -notmatch 'Remote Desktop|Virtual|Microsoft Basic|Display Adapter' })
        $gpuNames = ($gpus | ForEach-Object { $_.Caption }) -join " + "
        if (-not $gpuNames) { $gpuNames = "Sconosciuto" }
        $hasNvidia = $gpuNames -match 'NVIDIA'
        $hasAMDGpu = $gpuNames -match 'Radeon|AMD RX|AMD Vega'
        Write-FOMLog "GPU: $gpuNames" "INFO"
        Set-FOMProgress -Value 25 -Status "GPU rilevata..."

        # ── RAM ──────────────────────────────────────────────────────────────────
        $ramGB   = [math]::Round((Get-CimInstance Win32_ComputerSystem -EA SilentlyContinue).TotalPhysicalMemory / 1GB, 1)
        $lowRam  = $ramGB -lt 16
        $ramText = "$ramGB GB$(if ($lowRam) { '  (< 16 GB - kill aggressivo consigliato)' })"
        Write-FOMLog "RAM: $ramText" "INFO"
        Set-FOMProgress -Value 35 -Status "RAM rilevata..."

        # ── DISCO ─────────────────────────────────────────────────────────────────
        $hasNVMe = $false; $hasSSD = $false; $hasHDD = $false
        try {
            foreach ($d in @(Get-PhysicalDisk -EA SilentlyContinue)) {
                if     ($d.BusType -eq 'NVMe' -or $d.MediaType -eq 'NVMe') { $hasNVMe = $true }
                elseif ($d.MediaType -eq 'SSD' -or $d.SpindleSpeed -eq 0)  { $hasSSD  = $true }
                else                                                         { $hasHDD  = $true }
            }
        } catch {}
        $diskParts = @()
        if ($hasNVMe) { $diskParts += "NVMe SSD" }
        if ($hasSSD)  { $diskParts += "SATA SSD" }
        if ($hasHDD)  { $diskParts += "HDD" }
        $diskStr = if ($diskParts) { $diskParts -join " + " } else { "Sconosciuto" }
        Write-FOMLog "Disco: $diskStr" "INFO"
        Set-FOMProgress -Value 45 -Status "Disco rilevato..."

        # ── APP INSTALLATE ────────────────────────────────────────────────────────
        $hasSteam    = (Test-Path "$env:ProgramFiles(x86)\Steam\steam.exe")                       -or (Test-Path 'HKCU:\Software\Valve\Steam')
        $hasDiscord  = (Test-Path "$env:LocalAppData\Discord\Update.exe")                         -or (Test-Path 'HKCU:\Software\Discord')
        $hasCanary   = Test-Path "$env:LocalAppData\DiscordCanary\Update.exe"
        $hasSpotify  = (Test-Path "$env:AppData\Spotify\Spotify.exe")                            -or (Test-Path 'HKCU:\Software\Spotify AB\Spotify')
        $hasVanguard = $null -ne (Get-Service 'vgc' -EA SilentlyContinue)
        $hasEpic     = (Test-Path "$env:ProgramFiles\Epic Games\Launcher\Portal\Binaries\Win64")  -or (Test-Path "$env:ProgramData\Epic\EpicGamesLauncher")
        $hasBNet     = (Test-Path "$env:ProgramFiles(x86)\Battle.net\Battle.net.exe")             -or (Test-Path "$env:ProgramFiles(x86)\Blizzard Entertainment")
        $hasEAApp    = (Test-Path "$env:ProgramFiles\Electronic Arts\EA Desktop\EADesktop.exe")   -or (Test-Path "$env:ProgramFiles(x86)\Origin\Origin.exe")
        $hasOD       = (Test-Path "$env:LocalAppData\Microsoft\OneDrive\OneDrive.exe")            -or (Test-Path "$env:SystemRoot\SysWOW64\OneDriveSetup.exe")
        $hasTeams    = (Test-Path "$env:LocalAppData\Microsoft\Teams\current\Teams.exe")          -or (Test-Path "$env:LocalAppData\Packages\MSTeams_8wekyb3d8bbwe")
        $hasUbi      = (Test-Path "$env:ProgramFiles(x86)\Ubisoft\Ubisoft Game Launcher\upc.exe") -or (Test-Path "$env:ProgramFiles(x86)\Uplay\Uplay.exe")
        Write-FOMLog "App: Steam=$hasSteam Discord=$hasDiscord Canary=$hasCanary Spotify=$hasSpotify Vanguard=$hasVanguard Epic=$hasEpic BNet=$hasBNet EA=$hasEAApp OD=$hasOD Teams=$hasTeams Ubisoft=$hasUbi" "INFO"
        Set-FOMProgress -Value 60 -Status "App rilevate..."

        # ── SOFTWARE PERIFERICHE ──────────────────────────────────────────────────
        $hasRazer  = (Test-Path 'HKLM:\SOFTWARE\Razer')    -or (Test-Path "$env:ProgramFiles(x86)\Razer\Synapse3")
        $hasLogi   = (Test-Path 'HKLM:\SOFTWARE\Logitech') -or (Test-Path "$env:ProgramFiles\LGHUB\lghub.exe")
        $hasASUS   = ($null -ne (Get-Service 'ArmouryCrateSVC'  -EA SilentlyContinue)) -or (Test-Path "$env:ProgramFiles\ASUS\ARMOURY CRATE Service")
        $hasMSI    = ($null -ne (Get-Service 'MSICenterService' -EA SilentlyContinue)) -or (Test-Path "$env:ProgramFiles(x86)\MSI\MSI Center")
        $hasCors   = ($null -ne (Get-Service 'CorsairVBusDriver'-EA SilentlyContinue)) -or (Test-Path "$env:ProgramFiles\Corsair\CORSAIR iCUE 5 Software")
        $hasSSeries= (Test-Path "$env:ProgramFiles\SteelSeries\GG\SteelSeriesGG.exe")  -or ($null -ne (Get-Service 'SteelSeriesGG' -EA SilentlyContinue))
        $hasNahi   = $null -ne (Get-Service 'NahimicService' -EA SilentlyContinue)
        Write-FOMLog "Periferiche: Razer=$hasRazer Logitech=$hasLogi ASUS=$hasASUS MSI=$hasMSI Corsair=$hasCors SteelSeries=$hasSSeries Nahimic=$hasNahi" "INFO"
        Set-FOMProgress -Value 75 -Status "Periferiche rilevate..."

        # ── COSTRUISCI LISTA RACCOMANDAZIONI ──────────────────────────────────────
        $rec = [System.Collections.Generic.List[string]]::new()

        # GPU Nvidia → kill shadow e gfe
        if ($hasNvidia) {
            foreach ($tid in @('KillNvShadow','KillGeForceExp')) {
                if (-not $rec.Contains($tid)) { $rec.Add($tid) }
            }
            Write-FOMLog "Nvidia GPU: aggiunte raccomandazioni overlay Nvidia" "INFO"
        }

        # RAM < 16 GB → seleziona tutti i Kill sicuri
        if ($lowRam) {
            $sync.configs.tweaks.PSObject.Properties |
                Where-Object {
                    $_.Value.category -eq 'Processi' -and
                    (-not ($_.Value.PSObject.Properties['safe']) -or $_.Value.safe -ne $false)
                } |
                ForEach-Object { if (-not $rec.Contains($_.Name)) { $rec.Add($_.Name) } }
            Write-FOMLog "RAM < 16 GB: kill aggressivo di tutti i processi sicuri" "WARN"
        }

        # App startup mapping
        $appMap = [ordered]@{
            'StartupSteam'        = $hasSteam
            'StartupDiscord'      = $hasDiscord
            'StartupDiscordCanary'= $hasCanary
            'StartupSpotify'      = $hasSpotify
            'StartupVanguard'     = $hasVanguard
            'StartupEpicGames'    = $hasEpic
            'StartupBattleNet'    = $hasBNet
            'StartupEAApp'        = $hasEAApp
            'StartupOneDrive'     = $hasOD
            'StartupTeams'        = $hasTeams
            'StartupUbisoft'      = $hasUbi
        }
        foreach ($k in $appMap.Keys) {
            if ($appMap[$k] -and -not $rec.Contains($k)) { $rec.Add($k) }
        }

        # Periferiche mapping
        $hwMap = [ordered]@{
            'KillRazer'       = $hasRazer
            'KillLogitech'    = $hasLogi
            'KillArmouryCrate'= $hasASUS
            'KillMSICenter'   = $hasMSI
            'KillCorsairICUE' = $hasCors
            'KillSteelSeries' = $hasSSeries
            'KillNahimic'     = $hasNahi
        }
        foreach ($k in $hwMap.Keys) {
            if ($hwMap[$k] -and -not $rec.Contains($k)) { $rec.Add($k) }
        }

        Set-FOMProgress -Value 90 -Status "Applicazione selezioni..."

        # ── AGGIORNA UI ───────────────────────────────────────────────────────────
        $appList = @()
        if ($hasSteam)   { $appList += "Steam" }
        if ($hasDiscord) { $appList += "Discord" }
        if ($hasCanary)  { $appList += "Discord Canary" }
        if ($hasSpotify) { $appList += "Spotify" }
        if ($hasVanguard){ $appList += "Vanguard" }
        if ($hasEpic)    { $appList += "Epic Games" }
        if ($hasBNet)    { $appList += "Battle.net" }
        if ($hasEAApp)   { $appList += "EA App" }
        if ($hasOD)      { $appList += "OneDrive" }
        if ($hasTeams)   { $appList += "Teams" }
        if ($hasUbi)     { $appList += "Ubisoft" }

        $hwList = @()
        if ($hasRazer)   { $hwList += "Razer" }
        if ($hasLogi)    { $hwList += "Logitech" }
        if ($hasASUS)    { $hwList += "ASUS" }
        if ($hasMSI)     { $hwList += "MSI" }
        if ($hasCors)    { $hwList += "Corsair" }
        if ($hasSSeries) { $hwList += "SteelSeries" }
        if ($hasNahi)    { $hwList += "Nahimic" }

        $sync.ScanCpu  = $cpuName
        $sync.ScanGpu  = $gpuNames
        $sync.ScanRam  = $ramText
        $sync.ScanDisk = $diskStr
        $sync.ScanApps = if ($appList)   { $appList -join ", " } else { "nessuna rilevata" }
        $sync.ScanHw   = if ($hwList)    { $hwList  -join ", " } else { "nessuna rilevata" }
        $sync.ScanRec  = $rec
        $recCount      = $rec.Count

        $sync.Form.Dispatcher.Invoke([action]{
            if ($sync.TbHwCpu)        { $sync.TbHwCpu.Text        = $sync.ScanCpu  }
            if ($sync.TbHwGpu)        { $sync.TbHwGpu.Text        = $sync.ScanGpu  }
            if ($sync.TbHwRam)        { $sync.TbHwRam.Text        = $sync.ScanRam  }
            if ($sync.TbHwDisk)       { $sync.TbHwDisk.Text       = $sync.ScanDisk }
            if ($sync.TbHwApps)       { $sync.TbHwApps.Text       = $sync.ScanApps }
            if ($sync.TbHwPeripherals){ $sync.TbHwPeripherals.Text = $sync.ScanHw  }

            foreach ($tid in $sync.ScanRec) {
                $ck = $sync["ck_$tid"]
                if ($ck) { $ck.IsChecked = $true }
            }

            if ($sync.TbScanStatus) {
                $sync.TbScanStatus.Text = "Scansione completata - $($sync.ScanRec.Count) tweaks selezionati. Naviga nei tab e premi RUN TWEAKS."
                $sync.TbScanStatus.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#00E676")
            }
            if ($sync.BtnScanHardware) { $sync.BtnScanHardware.IsEnabled = $true }
        }, [System.Windows.Threading.DispatcherPriority]::Background)

        Set-FOMProgress -Value 100 -Status "Scansione completata"
        Write-FOMLog "═══════════════════════════════════════════" "INFO"
        Write-FOMLog "SCAN completato - $recCount tweaks selezionati automaticamente." "OK"
        Write-FOMLog "Naviga nei tab per rivedere le selezioni, poi premi RUN TWEAKS." "WARN"
        Set-FOMHeaderStatus "Scan completato - $recCount tweaks" "#00C8FF"
        $sync.ProcessRunning = $false
    }
}
