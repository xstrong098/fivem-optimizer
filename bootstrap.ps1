<#
    FiveM Performance Optimizer - Bootstrap
    =========================================
    Scarica e installa l'optimizer su qualsiasi PC con un solo comando.

    UTILIZZO - incolla in PowerShell (anche non admin):
    -------------------------------------------------------
    irm https://raw.githubusercontent.com/xstrong098/fivem-optimizer/main/bootstrap.ps1 | iex

    Oppure dalla finestra Esegui (Win+R):
        powershell -ep bypass -c "irm 'https://raw.githubusercontent.com/xstrong098/fivem-optimizer/main/bootstrap.ps1' | iex"
#>

$repoRaw    = "https://raw.githubusercontent.com/xstrong098/fivem-optimizer/main"
$installDir = "$env:LOCALAPPDATA\FiveM-Optimizer"

$ErrorActionPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host ""
Write-Host "  ================================================" -ForegroundColor Cyan
Write-Host "   FiveM Performance Optimizer - Bootstrap" -ForegroundColor Cyan
Write-Host "  ================================================" -ForegroundColor Cyan
Write-Host ""

# ── Auto-elevazione UAC con guard anti-loop ───────────────────────────────────
$isAdmin   = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$loopFlag  = "$env:TEMP\.fom_elev_attempt"

if (-not $isAdmin) {
    if (Test-Path $loopFlag) {
        # Secondo lancio senza admin = UAC rifiutato o terminale non compatibile
        Remove-Item $loopFlag -Force -EA SilentlyContinue
        Write-Host "  [X] Permessi amministratore non ottenuti." -ForegroundColor Red
        Write-Host ""
        Write-Host "  Soluzione: apri PowerShell come Amministratore (tasto destro)" -ForegroundColor Yellow
        Write-Host "  e incolla questo comando:" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  irm https://raw.githubusercontent.com/xstrong098/fivem-optimizer/main/bootstrap.ps1 | iex" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  Premi INVIO per chiudere."
        $null = $Host.UI.ReadLine()
        exit 1
    }

    # Primo tentativo: salva flag, scarica in temp e rilancia come admin
    New-Item $loopFlag -ItemType File -Force -EA SilentlyContinue | Out-Null
    Write-Host "  [!] Richiedo privilegi amministratore (UAC)..." -ForegroundColor Yellow

    $tmp = "$env:TEMP\fom-bootstrap.ps1"
    try {
        Invoke-WebRequest "$repoRaw/bootstrap.ps1" -OutFile $tmp -UseBasicParsing -EA Stop
    } catch {
        if ($MyInvocation.MyCommand.Path -and (Test-Path $MyInvocation.MyCommand.Path)) {
            $tmp = $MyInvocation.MyCommand.Path
        } else {
            Remove-Item $loopFlag -Force -EA SilentlyContinue
            Write-Host "  [X] Impossibile scaricare bootstrap. Controlla la connessione." -ForegroundColor Red
            Write-Host "  Premi INVIO per chiudere."
            $null = $Host.UI.ReadLine()
            exit 1
        }
    }

    Start-Process powershell.exe -ArgumentList @(
        '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $tmp
    ) -Verb RunAs
    exit
}

# Admin confermato: rimuovi il flag se rimasto (elevazione riuscita)
Remove-Item $loopFlag -Force -EA SilentlyContinue

# ── Lista file da scaricare ───────────────────────────────────────────────────
$files = @(
    "FiveM-Optimizer.ps1",
    "AVVIA-COME-ADMIN.bat",
    "config/tweaks.json",
    "config/lang/en.json",
    "xaml/MainWindow.xaml",
    "functions/private/Write-FOMLog.ps1",
    "functions/private/Set-FOMProgress.ps1",
    "functions/private/Set-FOMRegistry.ps1",
    "functions/private/Set-FOMService.ps1",
    "functions/private/Invoke-FOMTweaks.ps1",
    "functions/private/New-FOMRestorePoint.ps1",
    "functions/public/Invoke-FOMBuildUI.ps1",
    "functions/public/Invoke-FOMRunspace.ps1",
    "functions/public/Invoke-FOMScanHardware.ps1",
    "functions/public/Invoke-FOMTweaksButton.ps1",
    "tools/Blocca-WindowsUpdate.ps1"
)

# ── Controlla installazione esistente ─────────────────────────────────────────
$alreadyInstalled = Test-Path "$installDir\FiveM-Optimizer.ps1"
if ($alreadyInstalled) {
    Add-Type -AssemblyName PresentationFramework -EA SilentlyContinue
    $r = [System.Windows.MessageBox]::Show(
        "FiveM Optimizer e' gia' installato in:`n$installDir`n`nVuoi scaricare l'ultima versione da GitHub?",
        "FiveM Optimizer", "YesNo", "Question")
    if ($r -eq 'No') {
        Write-Host "  Avvio versione installata..." -ForegroundColor Green
        Start-Process powershell.exe -ArgumentList @(
            '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "$installDir\FiveM-Optimizer.ps1"
        )
        exit
    }
}

# ── Download ──────────────────────────────────────────────────────────────────
Write-Host "  Destinazione: $installDir" -ForegroundColor DarkGray
Write-Host ""

$total  = $files.Count
$i      = 0
$errors = 0

foreach ($f in $files) {
    $i++
    $localPath = Join-Path $installDir ($f -replace '/', '\')
    $localDir  = Split-Path $localPath -Parent
    New-Item -ItemType Directory -Path $localDir -Force -EA SilentlyContinue | Out-Null

    Write-Host "  [$($i.ToString().PadLeft(2))/$total] $f" -ForegroundColor DarkGray -NoNewline
    try {
        Invoke-WebRequest -Uri "$repoRaw/$f" -OutFile $localPath -UseBasicParsing -EA Stop
        Write-Host " OK" -ForegroundColor Green
    } catch {
        Write-Host " ERRORE: $_" -ForegroundColor Red
        $errors++
    }
}

Write-Host ""
if ($errors -gt 0) {
    Write-Host "  [!] $errors file non scaricati. Controlla la connessione o la repository." -ForegroundColor Yellow
    Write-Host ""
}

# ── Avvia optimizer ───────────────────────────────────────────────────────────
if (Test-Path "$installDir\FiveM-Optimizer.ps1") {
    Write-Host "  [+] Installazione completata. Avvio optimizer..." -ForegroundColor Green
    Write-Host ""
    # Lancia senza -Verb RunAs: siamo gia' admin, il processo figlio eredita il token
    Start-Process powershell.exe -ArgumentList @(
        '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "$installDir\FiveM-Optimizer.ps1"
    )
} else {
    Write-Host "  [X] FiveM-Optimizer.ps1 non trovato. Installazione fallita." -ForegroundColor Red
    Write-Host "  Premi INVIO per chiudere."
    $null = $Host.UI.ReadLine()
}
