# ⚡ FiveM Performance Optimizer

A modular Windows gaming optimizer built in PowerShell + WPF. Designed to eliminate CPU, RAM and disk spikes caused by background processes during FiveM / GTA V sessions. Data-driven: all tweaks live in `config/tweaks.json`, no hardcoded logic.

---

## Requirements

- Windows 10 / 11 (64-bit)
- PowerShell 5.1 (pre-installed on all modern Windows)
- Administrator privileges (the tool will request UAC elevation automatically)

---

## Quick Install — one command, any PC

Open PowerShell (even without admin) and paste:

```powershell
irm https://raw.githubusercontent.com/xstrong098/fivem-optimizer/main/bootstrap.ps1 | iex
```

Or from the **Run dialog (Win+R)**:

```
powershell -ep bypass -c "irm 'https://raw.githubusercontent.com/xstrong098/fivem-optimizer/main/bootstrap.ps1' | iex"
```

The bootstrap will:
1. Request UAC elevation automatically
2. Download all files to `%LOCALAPPDATA%\FiveM-Optimizer\`
3. Launch the optimizer

If already installed, it asks whether to update or just run.

---

## Manual Run (if you cloned the repo)

Right-click `AVVIA-COME-ADMIN.bat` and select **Run as administrator**.

Or from an elevated PowerShell:

```powershell
powershell -ep bypass -File "FiveM-Optimizer.ps1"
```

---

## How to Use

### 1. Select tweaks

Browse the tabs in the left sidebar. Each tweak shows:
- **Name** — what it does
- **Description** — technical detail below the name

**Color coding:**

| Color | Meaning |
|-------|---------|
| White | Safe — no side effects |
| Orange | Use with caution — read the description first |

### 2. Run

Click **RUN TWEAKS** to apply all checked tweaks.
The output console on the right shows real-time results for each tweak.

### 3. Undo

Click **Undo Tweaks** to revert all tweaks that have an undo script.
Not all tweaks are reversible (e.g. Debloat app removals).

### 4. Language

Use the **dropdown in the top-right corner** of the header to switch language.
Currently available: **Italiano**, **English**, **Espanol**

---

## Tab Reference

| Tab | What it contains |
|-----|-----------------|
| **Scanner** | Auto-detects your hardware and pre-checks the most relevant tweaks for your system |
| **Processi** | Kill background processes during gaming (Windows services, apps, overlays) |
| **Input** | Mouse, keyboard and USB/HID latency optimizations |
| **Gaming** | Game Mode, MMCSS, Nagle, timer resolution, Core Parking, MPO, FSO, IPv6 |
| **Sistema** | Privacy, telemetry, TCP stack, power throttling, shutdown speed |
| **Servizi** | Disable unnecessary Windows services (Xbox Live, SysMain, DiagTrack, etc.) |
| **Power & Tools** | Ultimate Performance plan, registry backup, Nvidia Inspector profile |
| **Debloat** | Remove bloatware apps, OneDrive, Xbox, Edge auto-start |
| **Personalizzazione** | File extensions, hidden files, taskbar, dark theme, right-click menu |
| **Avvio** | Disable auto-start for Steam, Discord, Spotify, Epic Games, EA App, etc. |

---

## Scanner Tab

Click **Scan Hardware** to automatically detect:

- **CPU** — Intel or AMD (applies relevant C-State / Boost tweaks)
- **GPU** — Nvidia (auto-checks ShadowPlay, GeForce Experience kill)
- **RAM** — if under 16 GB, marks aggressive process kills as recommended
- **Installed apps** — Steam, Discord, Spotify, Epic, Battle.net, EA App, Ubisoft, OneDrive, Teams
- **Peripherals** — Razer, Logitech, ASUS, MSI, Corsair, SteelSeries, Nahimic

After the scan, relevant tweaks are automatically pre-checked.

---

## Windows Update Blocker (standalone)

To block or restore Windows Update **without opening the full optimizer**:

```powershell
powershell -ep bypass -File "tools\Blocca-WindowsUpdate.ps1"
```

It detects the current state and shows a dialog: **Block** or **Restore**.

What it blocks:
- Services: `wuauserv`, `UsoSvc`, `DoSvc`, `TrustedInstaller` (parent of TiWorker.exe)
- Registry: `WaaSMedicSvc Start=4` (best-effort — protected service)
- Scheduled task: `\Microsoft\Windows\WindowsUpdate\Scheduled Start`
- Group Policy: `AU NoAutoUpdate=1`, pause timestamps until 2038

---

## Build EXE (optional)

To compile standalone `.exe` files (requires internet on first run to install `ps2exe`):

```powershell
powershell -ep bypass -File "Build-Exe.ps1"
```

Output:
- `FiveM-Optimizer.exe` — full GUI optimizer
- `tools\Blocca-WindowsUpdate.exe` — standalone Windows Update block tool

> The `.exe` still requires the `config\`, `functions\` and `xaml\` folders next to it.

---

## Add a Language

1. Copy `config/lang/en.json`
2. Rename it to your language code (e.g. `fr.json`, `de.json`, `pt.json`)
3. Translate the `Content` and `Description` values for each tweak
4. Push to the repo — the optimizer detects it automatically in the language dropdown

Language files are loaded at startup based on the Windows system locale (`Get-UICulture`), with English as fallback for unsupported locales.

---

## Project Structure

```
FiveM-Optimizer/
├── FiveM-Optimizer.ps1          # Main entry point
├── bootstrap.ps1                # Remote one-liner installer
├── AVVIA-COME-ADMIN.bat         # Double-click launcher
├── Build-Exe.ps1                # Compile to EXE via ps2exe
├── config/
│   ├── tweaks.json              # All 153 tweaks (Italian base language)
│   └── lang/
│       ├── en.json              # English translations
│       └── es.json              # Spanish translations
├── xaml/
│   └── MainWindow.xaml          # WPF UI layout and styles
├── functions/
│   ├── private/                 # Internal helpers (log, registry, service, progress)
│   └── public/                  # UI builders, tweak runner, scanner, language switch
└── tools/
    └── Blocca-WindowsUpdate.ps1 # Standalone Windows Update manager
```
