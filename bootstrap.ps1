<#
    FiveM Performance Optimizer - Bootstrap
    =========================================
    Scarica e installa l'optimizer su qualsiasi PC con un solo comando.

    UTILIZZO (incolla in PowerShell, anche non admin):
    -------------------------------------------------------
    irm https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/bootstrap.ps1 | iex

    Oppure dalla finestra Esegui (Win+R):
        powershell -ep bypass -c "irm 'https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/bootstrap.ps1' | iex"

    PRIMA DI PUBBLICARE SU GITHUB:
        Sostituisci YOUR_USERNAME e YOUR_REPO con i tuoi dati GitHub nella variabile $repoRaw qui sotto.
#>

# ── CONFIGURA QUI LA TUA REPOSITORY GITHUB ───────────────────────────────────
$repoRaw    = "https://raw.githubusercontent.com/xstrong098/fivem-optimizer/main"
$installDir = "$env:LOCALAPPDATA\FiveM-Optimizer"
# ─────────────────────────────────────────────────────────────────────────────

$ErrorActionPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host ""
Write-Host "  ================================================" -ForegroundColor Cyan
Write-Host "   FiveM Performance Optimizer - Bootstrap" -ForegroundColor Cyan
Write-Host "  ================================================" -ForegroundColor Cyan
Write-Host ""

# ── Auto-elevazione UAC ───────────────────────────────────────────────────────
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole('Administrator')
if (-not $isAdmin) {
    Write-Host "  [!] Richiedo privilegi amministratore..." -ForegroundColor Yellow
    $tmp = "$env:TEMP\fom-bootstrap.ps1"
    try {
        Invoke-WebRequest "$repoRaw/bootstrap.ps1" -OutFile $tmp -UseBasicParsing -EA Stop
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$tmp`"" -Verb RunAs
    } catch {
        # Fallback: se eseguito come file locale rilanciamo quello
        $self = if ($MyInvocation.MyCommand.Path) { $MyInvocation.MyCommand.Path } else { $null }
        if ($self -and (Test-Path $self)) {
            Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$self`"" -Verb RunAs
        } else {
            Write-Host "  [X] Impossibile auto-elevarsi. Riapri PowerShell come Amministratore e riesegui." -ForegroundColor Red
            Write-Host "      Premi INVIO per uscire."
            $null = $Host.UI.ReadLine()
        }
    }
    exit
}

# ── Lista completa dei file da scaricare ──────────────────────────────────────
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
    $msg = "FiveM Optimizer e' gia' installato in:`n$installDir`n`nVuoi scaricare l'ultima versione da GitHub?"
    $r = [System.Windows.MessageBox]::Show($msg, "FiveM Optimizer", "YesNo", "Question")
    if ($r -eq 'No') {
        Write-Host "  Avvio versione installata..." -ForegroundColor Green
        Write-Host ""
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$installDir\FiveM-Optimizer.ps1`"" -Verb RunAs
        exit
    }
}

# ── Download files ────────────────────────────────────────────────────────────
Write-Host "  Cartella installazione: $installDir" -ForegroundColor DarkGray
Write-Host ""

$total   = $files.Count
$i       = 0
$errors  = 0

foreach ($f in $files) {
    $i++
    $localPath = Join-Path $installDir ($f -replace '/', '\')
    $localDir  = Split-Path $localPath -Parent
    New-Item -ItemType Directory -Path $localDir -Force -EA SilentlyContinue | Out-Null

    $url = "$repoRaw/$f"
    $pct = [math]::Round(($i / $total) * 100)
    Write-Host "  [$($i.ToString().PadLeft(2))/$total] $f" -ForegroundColor DarkGray -NoNewline

    try {
        Invoke-WebRequest -Uri $url -OutFile $localPath -UseBasicParsing -EA Stop
        Write-Host " OK" -ForegroundColor Green
    } catch {
        Write-Host " ERRORE" -ForegroundColor Red
        Write-Host "         URL: $url" -ForegroundColor DarkRed
        Write-Host "         $_" -ForegroundColor DarkRed
        $errors++
    }
}

Write-Host ""

if ($errors -gt 0) {
    Write-Host "  [!] $errors file non scaricati. Controlla la connessione o l'URL della repository." -ForegroundColor Yellow
    Write-Host ""
}

if (Test-Path "$installDir\FiveM-Optimizer.ps1") {
    Write-Host "  [+] Download completato. Avvio optimizer..." -ForegroundColor Green
    Write-Host ""
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$installDir\FiveM-Optimizer.ps1`"" -Verb RunAs
} else {
    Write-Host "  [X] FiveM-Optimizer.ps1 non trovato. Installazione fallita." -ForegroundColor Red
    Write-Host "      Premi INVIO per uscire."
    $null = $Host.UI.ReadLine()
}
