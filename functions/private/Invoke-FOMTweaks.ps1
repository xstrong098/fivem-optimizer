function Invoke-FOMTweaks {
    param($TweakID, [bool]$Undo = $false)

    $tweak = $sync.configs.tweaks.$TweakID
    if (-not $tweak) {
        Write-FOMLog "Tweak non trovato: $TweakID" "WARN"
        return
    }

    Write-FOMLog "$($tweak.Content)" "TITLE"

    $regKey    = if ($Undo) { "OriginalValue" } else { "Value"       }
    $svcKey    = if ($Undo) { "OriginalType"  } else { "StartupType" }
    $scriptKey = if ($Undo) { "UndoScript"    } else { "InvokeScript"}

    if ($tweak.registry) {
        $tweak.registry | ForEach-Object {
            $val = $_.$regKey
            if ($null -ne $val) {
                Set-FOMRegistry -Name $_.Name -Path $_.Path -Type $_.Type -Value $val
            }
        }
    }

    if ($tweak.service) {
        $tweak.service | ForEach-Object {
            $st = $_.$svcKey
            if ($st) { Set-FOMService -Name $_.Name -StartupType $st }
        }
    }

    if ($tweak.$scriptKey) {
        $tweak.$scriptKey | ForEach-Object {
            if ($_ -and $_.Trim() -ne "") {
                try {
                    $sb = [scriptblock]::Create($_)
                    & $sb
                } catch {
                    Write-FOMLog "Errore script $TweakID`: $_" "ERROR"
                }
            }
        }
    }

    Write-FOMLog "$($tweak.Content) - OK" "OK"
}
