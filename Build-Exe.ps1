<#
    Build-Exe.ps1
    Compila i PS1 in EXE standalone usando ps2exe (PSGallery).
    Eseguire da PowerShell come Amministratore.

    Output:
        FiveM-Optimizer.exe               <- optimizer principale con GUI
        tools\Blocca-WindowsUpdate.exe    <- tool standalone Windows Update
#>

Set-StrictMode -Off
$ErrorActionPreference = 'Continue'
$root = $PSScriptRoot

Write-Host ""
Write-Host "  FiveM Optimizer - Build EXE" -ForegroundColor Cyan
Write-Host "  =============================" -ForegroundColor Cyan
Write-Host ""

# ── Installa ps2exe se mancante ───────────────────────────────────────────────
if (-not (Get-Module -ListAvailable -Name ps2exe -EA SilentlyContinue)) {
    Write-Host "  [i] Installazione modulo ps2exe da PSGallery..." -ForegroundColor Yellow
    try {
        Install-Module ps2exe -Scope CurrentUser -Force -Repository PSGallery -EA Stop
        Write-Host "  [+] ps2exe installato." -ForegroundColor Green
    } catch {
        Write-Host "  [X] Errore installazione ps2exe: $_" -ForegroundColor Red
        Write-Host "      Installa manualmente: Install-Module ps2exe -Scope CurrentUser -Force" -ForegroundColor Red
        pause; exit 1
    }
}
Import-Module ps2exe -EA Stop

# ── Helper di build ───────────────────────────────────────────────────────────
function Build-Script {
    param(
        [string]$In,
        [string]$Out,
        [string]$Title,
        [string]$Desc,
        [string]$Ver = "3.0.0.0"
    )
    Write-Host "  >> Compilo: $(Split-Path $In -Leaf)" -ForegroundColor Cyan

    $params = @{
        inputFile    = $In
        outputFile   = $Out
        noConsole    = $true
        requireAdmin = $true
        title        = $Title
        description  = $Desc
        product      = "FiveM Optimizer"
        version      = $Ver
    }

    # Aggiungi icona se presente
    $iconPath = "$root\assets\icon.ico"
    if (Test-Path $iconPath) { $params.iconFile = $iconPath }

    try {
        Invoke-ps2exe @params
        if (Test-Path $Out) {
            $kb = [math]::Round((Get-Item $Out).Length / 1KB)
            Write-Host "  [+] OK -> $(Split-Path $Out -Leaf) ($kb KB)" -ForegroundColor Green
        } else {
            Write-Host "  [!] File EXE non trovato dopo la compilazione." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  [X] Errore compilazione: $_" -ForegroundColor Red
    }
}

# ── Build 1: Optimizer principale ─────────────────────────────────────────────
Build-Script `
    -In    "$root\FiveM-Optimizer.ps1" `
    -Out   "$root\FiveM-Optimizer.exe" `
    -Title "FiveM Performance Optimizer" `
    -Desc  "FiveM Performance Optimizer v3.0 - Gaming tweak suite" `
    -Ver   "3.0.0.0"

# ── Build 2: Tool standalone Windows Update ───────────────────────────────────
Build-Script `
    -In    "$root\tools\Blocca-WindowsUpdate.ps1" `
    -Out   "$root\tools\Blocca-WindowsUpdate.exe" `
    -Title "Windows Update Manager" `
    -Desc  "Blocca o ripristina Windows Update con un click" `
    -Ver   "1.0.0.0"

# ── Riepilogo ─────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  Build completata." -ForegroundColor Green
Write-Host ""

$results = @(
    @{ File = "$root\FiveM-Optimizer.exe";            Label = "Optimizer completo" },
    @{ File = "$root\tools\Blocca-WindowsUpdate.exe"; Label = "Standalone WU block" }
)

foreach ($r in $results) {
    if (Test-Path $r.File) {
        Write-Host "  [+] $($r.Label): $($r.File)" -ForegroundColor Green
    } else {
        Write-Host "  [ ] $($r.Label): non compilato" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "  NOTA: tieni i file config\, functions\, xaml\ nella stessa" -ForegroundColor DarkGray
Write-Host "        cartella dell'EXE per il funzionamento del GUI optimizer." -ForegroundColor DarkGray
Write-Host ""

pause
