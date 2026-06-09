# ── Auto-elevazione UAC ───────────────────────────────────────────────────────
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole('Administrator')) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName PresentationFramework

# ── Stato attuale ─────────────────────────────────────────────────────────────
$wuSvc    = Get-Service 'wuauserv' -EA SilentlyContinue
$isActive = $wuSvc -and $wuSvc.StartType -ne 'Disabled'
$stateMsg = if ($isActive) { "ATTIVO" } else { "BLOCCATO" }
$stateClr = if ($isActive) { "Windows Update e' attualmente: ATTIVO`n`nVuoi BLOCCARLO?" } `
                           else { "Windows Update e' attualmente: BLOCCATO`n`nVuoi RIPRISTINARLO?" }

$btn = if ($isActive) { [System.Windows.MessageBoxButton]::YesNoCancel } `
                      else { [System.Windows.MessageBoxButton]::YesNoCancel }

$r = [System.Windows.MessageBox]::Show(
    $stateClr,
    "FiveM - Windows Update Manager",
    [System.Windows.MessageBoxButton]::YesNoCancel,
    [System.Windows.MessageBoxImage]::Question)

if ($r -eq 'Cancel' -or $r -eq 'None') { exit }

# ── BLOCCA ────────────────────────────────────────────────────────────────────
if (($isActive -and $r -eq 'Yes') -or (-not $isActive -and $r -eq 'No')) {
    $svcs = @('wuauserv','UsoSvc','DoSvc','WaaSMedicSvc','TrustedInstaller')
    foreach ($s in $svcs) {
        Stop-Service  $s -Force -EA SilentlyContinue
        Set-Service   $s -StartupType Disabled -EA SilentlyContinue
    }
    Set-Service 'bits' -StartupType Manual -EA SilentlyContinue

    # WaaSMedicSvc via registro (protected service)
    Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc' `
        -Name 'Start' -Value 4 -Type DWord -EA SilentlyContinue

    # Scheduled task
    Disable-ScheduledTask -TaskPath '\Microsoft\Windows\WindowsUpdate\' `
        -TaskName 'Scheduled Start' -EA SilentlyContinue

    # Policy AU
    New-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'    -Force -EA SilentlyContinue | Out-Null
    New-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Force -EA SilentlyContinue | Out-Null
    $au = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
    Set-ItemProperty $au -Name 'NoAutoUpdate' -Value 1 -Type DWord -EA SilentlyContinue
    Set-ItemProperty $au -Name 'AUOptions'    -Value 1 -Type DWord -EA SilentlyContinue

    # Pause timestamps fino al 2038
    $ux = 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'
    foreach ($k in @('PauseUpdatesExpiryTime','PauseQualityUpdatesExpiryTime','PauseFeatureUpdatesExpiryTime')) {
        Set-ItemProperty $ux -Name $k -Value '2038-01-19T03:14:07Z' -Type String -EA SilentlyContinue
    }

    [System.Windows.MessageBox]::Show(
        "Windows Update BLOCCATO.`n`nServizi disabilitati:`n- wuauserv, UsoSvc, DoSvc`n- TrustedInstaller (blocca TiWorker)`n- WaaSMedicSvc (best-effort)`n`nPolicy AU + pause fino al 2038 applicate.`n`nRilancia questo script per ripristinare.",
        "Bloccato", "OK", "Information") | Out-Null
}

# ── RIPRISTINA ────────────────────────────────────────────────────────────────
else {
    # WaaSMedicSvc Manual
    Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc' `
        -Name 'Start' -Value 3 -Type DWord -EA SilentlyContinue

    foreach ($s in @('wuauserv','UsoSvc','DoSvc','TrustedInstaller')) {
        Set-Service   $s -StartupType Manual -EA SilentlyContinue
        Start-Service $s -EA SilentlyContinue
    }

    Enable-ScheduledTask -TaskPath '\Microsoft\Windows\WindowsUpdate\' `
        -TaskName 'Scheduled Start' -EA SilentlyContinue

    $au = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
    Remove-ItemProperty $au -Name 'NoAutoUpdate' -EA SilentlyContinue
    Remove-ItemProperty $au -Name 'AUOptions'    -EA SilentlyContinue

    $ux = 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'
    foreach ($k in @('PauseUpdatesExpiryTime','PauseQualityUpdatesExpiryTime','PauseFeatureUpdatesExpiryTime')) {
        Remove-ItemProperty $ux -Name $k -EA SilentlyContinue
    }

    [System.Windows.MessageBox]::Show(
        "Windows Update RIPRISTINATO.`n`nServizi riabilitati:`n- wuauserv, UsoSvc, DoSvc, TrustedInstaller`n`nPolicy AU e pause timestamps rimossi.",
        "Ripristinato", "OK", "Information") | Out-Null
}
