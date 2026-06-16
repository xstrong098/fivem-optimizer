# ⚡ FiveM Performance Optimizer
<img width="2553" height="1370" alt="image" src="https://github.com/user-attachments/assets/986a4be8-6578-4c5e-9d03-1d4caf9c64e9" />


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

## Nvidia Profile Inspector

The **Power & Tools** tab contains two Nvidia-specific tweaks that work together to apply a custom low-latency GPU profile for FiveM / GTA V.

### What is Nvidia Profile Inspector?

[Nvidia Profile Inspector (NPI)](https://github.com/Orbmu2k/nvidiaProfileInspector) is a third-party tool that exposes hidden driver-level settings not available in the standard Nvidia Control Panel. It lets you create and apply per-game profiles with advanced parameters.

### The .nip profile file

The optimizer ships with a pre-configured profile at `config\profile.nip`. This file contains the following settings optimized for FiveM:

| Setting | Value | Effect |
|---------|-------|--------|
| VSync | Off | Eliminates forced frame sync from driver level |
| Adaptive Tear Control | On | Alternative to VSync — avoids tearing without input lag penalty |
| Max Pre-Rendered Frames | 1 | Reduces GPU queue depth → lower input lag |
| Power Management Mode | Max Performance | Forces GPU to stay at max clock, no throttling |
| Threaded Optimization | On | Distributes DX draw calls across CPU threads |
| FXAA | Off | Disables driver-level anti-aliasing injection |
| Triple Buffering | Off | Reduces frame latency in windowed/borderless mode |
| Preferred Refresh Rate | Highest Available | Forces max refresh rate in DX games |
| FRL Low Latency | On | Frame Rate Limiter low-latency mode |

### How to use

**Step 1 — Export the profile copy to Desktop**

In the **Power & Tools** tab, check and run:
> **Export Nvidia Inspector Profile (Custom)**

This copies `config\profile.nip` to your Desktop so you can find it easily. The original file in `config\` is never modified.

**Step 2 — Install and launch NPI with the profile loaded**

Check and run:
> **Install and Launch NV Inspector + Profile**

This will:
1. Download `nvidiaProfileInspector.exe` from GitHub into `tools\nvidiaProfileInspector\` (only on first use — internet required)
2. Launch NPI with the `.nip` profile already loaded

**Step 3 — Import in NPI**

When NPI opens with the profile loaded, click **Import** (top toolbar) if the profile is not already active, then click **Apply changes** (top right).

> **Note:** The profile targets FiveM and GTA V executables. If you use a different exe name, you can duplicate the profile inside NPI and rename it.

