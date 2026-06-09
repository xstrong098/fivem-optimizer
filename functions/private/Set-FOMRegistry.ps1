function Set-FOMRegistry {
    param($Name, $Path, $Type, $Value)
    try {
        if (!(Test-Path $Path)) {
            New-Item -Path $Path -Force -ErrorAction Stop | Out-Null
        }
        if ($Value -ne "<RemoveEntry>") {
            Set-ItemProperty -Path $Path -Name $Name -Type $Type -Value $Value -Force -ErrorAction Stop | Out-Null
            Write-FOMLog "  $Path\$Name = $Value" "STEP"
        } else {
            Remove-ItemProperty -Path $Path -Name $Name -Force -ErrorAction SilentlyContinue
            Write-FOMLog "  Rimosso $Path\$Name" "STEP"
        }
    } catch [System.Security.SecurityException] {
        Write-FOMLog "Accesso negato: $Path\$Name" "ERROR"
    } catch [System.Management.Automation.ItemNotFoundException] {
        Write-FOMLog "Chiave non trovata: $Path" "WARN"
    } catch [System.UnauthorizedAccessException] {
        Write-FOMLog "Non autorizzato: $Path\$Name" "ERROR"
    } catch {
        Write-FOMLog "Errore su $Name`: $_" "ERROR"
    }
}
