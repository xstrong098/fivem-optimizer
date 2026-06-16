#Requires -RunAsAdministrator
<#
.SYNOPSIS
    FiveM Performance Optimizer v3.0
    Architettura modulare ispirata a WinUtil (ChrisTitusTech)
    $sync condiviso, RunspacePool, tweaks data-driven da config/tweaks.json
#>

# ── Assemblies ────────────────────────────────────────────────
Add-Type -AssemblyName PresentationFramework -ErrorAction Stop
Add-Type -AssemblyName PresentationCore      -ErrorAction Stop
Add-Type -AssemblyName WindowsBase           -ErrorAction Stop
Add-Type -AssemblyName System.Windows.Forms  -ErrorAction Stop

# ── $sync: stato condiviso tra UI thread e runspace ──────────
$sync = [Hashtable]::Synchronized(@{})
$sync.PSScriptRoot   = $PSScriptRoot
$sync.version        = "3.0"
$sync.configs        = @{}
$sync.ProcessRunning = $false

# ── Config ────────────────────────────────────────────────────
try {
    $sync.configs.tweaks = Get-Content "$PSScriptRoot\config\tweaks.json" `
        -Raw -Encoding UTF8 | ConvertFrom-Json
} catch {
    [System.Windows.MessageBox]::Show(
        "Impossibile caricare config\tweaks.json:`n$_",
        "Errore", "OK", "Error") | Out-Null
    exit 1
}
# Copia originale italiano PRIMA dell'overlay (serve per switching lingua verso IT)
$sync.configs.tweaksBase = Get-Content "$PSScriptRoot\config\tweaks.json" -Raw -Encoding UTF8 | ConvertFrom-Json

# ── Localizzazione (lang overlay) ────────────────────────────
# Baseline = italiano (tweaks.json). Per altre lingue carica config\lang\<codice>.json.
# Se manca la lingua, fallback a en.json.
$uiLang = (Get-UICulture).TwoLetterISOLanguageName
if ($uiLang -ne 'it') {
    $langFile = "$PSScriptRoot\config\lang\$uiLang.json"
    if (-not (Test-Path $langFile)) {
        $langFile = "$PSScriptRoot\config\lang\en.json"
    }
    if (Test-Path $langFile) {
        try {
            $langData = Get-Content $langFile -Raw -Encoding UTF8 | ConvertFrom-Json
            $langData.PSObject.Properties | ForEach-Object {
                $id = $_.Name
                if ($sync.configs.tweaks.$id) {
                    if ($_.Value.Content)     { $sync.configs.tweaks.$id.Content     = $_.Value.Content     }
                    if ($_.Value.Description) { $sync.configs.tweaks.$id.Description = $_.Value.Description }
                }
            }
        } catch {}
    }
}
$sync.currentLang = if ($null -eq $langFile) { 'it' } else { [System.IO.Path]::GetFileNameWithoutExtension($langFile) }

# ── Dot-source tutte le funzioni ──────────────────────────────
Get-ChildItem "$PSScriptRoot\functions\private\*.ps1" |
    ForEach-Object { . $_.FullName }
Get-ChildItem "$PSScriptRoot\functions\public\*.ps1"  |
    ForEach-Object { . $_.FullName }

# ── RunspacePool (WinUtil pattern) ───────────────────────────
$maxThreads        = [int]$env:NUMBER_OF_PROCESSORS
$hashVars          = New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry `
                         -ArgumentList 'sync', $sync, $null
$iss               = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
$iss.Variables.Add($hashVars)

# Carica tutte le funzioni FOM nel runspace
Get-ChildItem function:\ |
    Where-Object { $_.Name -imatch 'FOM' } |
    ForEach-Object {
        $def   = Get-Content "function:\$($_.Name)"
        $entry = New-Object System.Management.Automation.Runspaces.SessionStateFunctionEntry `
                     -ArgumentList $_.Name, $def
        $iss.Commands.Add($entry)
    }

$sync.runspace = [runspacefactory]::CreateRunspacePool(1, $maxThreads, $iss, $Host)
$sync.runspace.Open()

# ── Carica XAML ───────────────────────────────────────────────
$xamlPath = "$PSScriptRoot\xaml\MainWindow.xaml"
try {
    $inputXML    = (Get-Content $xamlPath -Raw -Encoding UTF8) -replace 'x:Name', 'Name'
    [xml]$xaml   = $inputXML
    $reader      = New-Object System.Xml.XmlNodeReader $xaml
    $sync.Form   = [Windows.Markup.XamlReader]::Load($reader)
} catch {
    [System.Windows.MessageBox]::Show(
        "Errore caricamento UI:`n$_`n`nVerifica xaml\MainWindow.xaml",
        "Errore", "OK", "Error") | Out-Null
    exit 1
}

# Bind tutti gli elementi con Name in $sync
$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    $sync[$_.Name] = $sync.Form.FindName($_.Name)
}

# ── Sysinfo status bar ────────────────────────────────────────
try {
    $cpu = (Get-WmiObject Win32_Processor | Select-Object -First 1).Name
    $ram = [math]::Round((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 1)
    $sync.SysInfo.Text = "$cpu  |  $ram GB RAM"
} catch {}

# ── Costruisci UI dai tweaks.json ─────────────────────────────
Invoke-FOMBuildUI

# ── Bottoni globali ───────────────────────────────────────────
$sync.RunTweaksButton.Add_Click({ Invoke-FOMTweaksButton })
$sync.UndoButton.Add_Click(     { Invoke-FOMTweaksButton -Undo $true })

$sync.BtnSelectAll.Add_Click({
    foreach ($key in @($sync.Keys)) {
        if ($key -match '^ck_') {
            $twId  = $key -replace '^ck_', ''
            $tweak = $sync.configs.tweaks.$twId
            if ($tweak -and (-not ($tweak.PSObject.Properties["safe"]) -or $tweak.safe -ne $false)) {
                $sync[$key].IsChecked = $true
            }
        }
    }
})

$sync.BtnClearAll.Add_Click({
    foreach ($key in @($sync.Keys)) {
        if ($key -match '^ck_') { $sync[$key].IsChecked = $false }
    }
})

# ── Messaggio di benvenuto nella console ─────────────────────
Write-FOMLog "FiveM Performance Optimizer v3.0 - avviato" "OK"
Write-FOMLog "OS: $([System.Environment]::OSVersion.VersionString)" "INFO"
Write-FOMLog "Tweaks disponibili: $($sync.configs.tweaks.PSObject.Properties.Count)" "INFO"
Write-FOMLog "────────────────────────────────────────────────────" "INFO"
Write-FOMLog "Seleziona un tab a sinistra, configura i tweaks e premi RUN TWEAKS." "INFO"
Write-FOMLog "CONSIGLIO: esegui prima 'Backup Registro' dal tab Power." "WARN"

# ── Pulizia alla chiusura ─────────────────────────────────────
$sync.Form.Add_Closing({
    $sync.runspace.Dispose()
    $sync.runspace.Close()
    [System.GC]::Collect()
})

# ── Avvia UI ──────────────────────────────────────────────────
$sync.Form.ShowDialog() | Out-Null