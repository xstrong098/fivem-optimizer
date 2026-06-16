function Invoke-FOMBuildUI {
    $tabOrder = @("Scanner","Processi","Input","Gaming","Sistema","Servizi","Power","Debloat","Personalizzazione","Avvio")

    # Group tweaks by category, sorted by Order
    $byCategory = @{}
    $sync.configs.tweaks.PSObject.Properties | ForEach-Object {
        $cat = $_.Value.category
        if (-not $byCategory[$cat]) { $byCategory[$cat] = [System.Collections.Generic.List[object]]::new() }
        $byCategory[$cat].Add([PSCustomObject]@{ Id = $_.Name; Tweak = $_.Value })
    }

    # Build one StackPanel per tab
    $panels = @{}
    foreach ($cat in $tabOrder) {

        # Scanner tab gets a custom panel (not the standard tweak-card loop)
        if ($cat -eq "Scanner") {
            $panels[$cat] = New-FOMScannerPanel
            continue
        }

        $sp = New-Object System.Windows.Controls.StackPanel
        $sp.Margin = [System.Windows.Thickness]::new(0,2,0,0)

        $items = if ($byCategory[$cat]) {
            @($byCategory[$cat] | Sort-Object { $_.Tweak.Order })
        } else { @() }

        foreach ($item in $items) {
            $id    = $item.Id
            $tweak = $item.Tweak

            # Card border
            $card = New-Object System.Windows.Controls.Border
            $card.Background      = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#1C2333")
            $card.BorderBrush     = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#252D42")
            $card.BorderThickness = [System.Windows.Thickness]::new(1)
            $card.CornerRadius    = [System.Windows.CornerRadius]::new(5)
            $card.Padding         = [System.Windows.Thickness]::new(12,9,12,9)
            $card.Margin          = [System.Windows.Thickness]::new(0,0,0,5)

            $cardSP = New-Object System.Windows.Controls.StackPanel

            # Checkbox
            $ck           = New-Object System.Windows.Controls.CheckBox
            $ck.Content   = $tweak.Content
            $ck.IsChecked = if ($null -ne $tweak.Checked) { [bool]$tweak.Checked } else { $true }
            $ck.FontSize  = 13
            $ck.FontWeight = [System.Windows.FontWeights]::SemiBold
            $ck.Margin    = [System.Windows.Thickness]::new(0,0,0,3)

            # Color: orange for non-safe, white otherwise
            $fgColor = if ($tweak.PSObject.Properties["safe"] -and $tweak.safe -eq $false) { "#FFAB40" } else { "#E2EAF8" }
            $ck.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString($fgColor)

            $cardSP.Children.Add($ck) | Out-Null

            if ($tweak.Description) {
                $desc              = New-Object System.Windows.Controls.TextBlock
                $desc.Text         = $tweak.Description
                $desc.FontSize     = 11
                $desc.Foreground   = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#5A6A8A")
                $desc.TextWrapping = [System.Windows.TextWrapping]::Wrap
                $desc.Margin       = [System.Windows.Thickness]::new(22,0,0,0)
                $cardSP.Children.Add($desc) | Out-Null
                $sync["desc_$id"] = $desc
            }

            $card.Child = $cardSP
            $sp.Children.Add($card) | Out-Null

            # Store ref in $sync so Invoke-FOMTweaksButton can find it
            $sync["ck_$id"] = $ck
        }

        $panels[$cat] = $sp
    }
    $sync.fomPanels = $panels

    # Wire nav buttons
    foreach ($cat in $tabOrder) {
        $btn = $sync["NavBtn_$cat"]
        if ($btn) {
            $c = $cat   # capture for closure
            $btn.Add_Click({ Invoke-FOMSwitchTab $c }.GetNewClosure())
        }
    }

    # Load first tab (Scanner)
    Invoke-FOMSwitchTab $tabOrder[0]

    # ── Populate language ComboBox ─────────────────────────────────────────────
    $langDisplay = @{ 'it' = 'IT  Italiano'; 'en' = 'EN  English'; 'es' = 'ES  Espanol' }
    $langDir     = "$($sync.PSScriptRoot)\config\lang"

    $sync.LangCombo.Items.Clear()

    $itItem         = New-Object System.Windows.Controls.ComboBoxItem
    $itItem.Content = 'IT  Italiano'
    $itItem.Tag     = 'it'
    $sync.LangCombo.Items.Add($itItem) | Out-Null

    if (Test-Path $langDir) {
        Get-ChildItem "$langDir\*.json" | Sort-Object BaseName | ForEach-Object {
            $code         = $_.BaseName
            $lItem        = New-Object System.Windows.Controls.ComboBoxItem
            $lItem.Content = if ($langDisplay[$code]) { $langDisplay[$code] } else { $code.ToUpper() }
            $lItem.Tag    = $code
            $sync.LangCombo.Items.Add($lItem) | Out-Null
        }
    }

    foreach ($item in $sync.LangCombo.Items) {
        if ($item.Tag -eq $sync.currentLang) { $sync.LangCombo.SelectedItem = $item; break }
    }

    $sync.LangCombo.Add_SelectionChanged({
        $item = $sync.LangCombo.SelectedItem
        if ($item -and $item.Tag) { Invoke-FOMSwitchLanguage -LangCode ([string]$item.Tag) }
    })
}

function Invoke-FOMSwitchLanguage {
    param([string]$LangCode)

    $sync.currentLang = $LangCode

    # Carica il file lingua (null per italiano = testo base da tweaksBase)
    $langData = $null
    if ($LangCode -ne 'it') {
        $f = "$($sync.PSScriptRoot)\config\lang\$LangCode.json"
        if (Test-Path $f) {
            try { $langData = Get-Content $f -Raw -Encoding UTF8 | ConvertFrom-Json } catch {}
        }
    }

    $sync.configs.tweaks.PSObject.Properties | ForEach-Object {
        $id   = $_.Name
        $base = $sync.configs.tweaksBase.$id   # testo originale italiano sempre disponibile

        $ck = $sync["ck_$id"]
        if ($ck) {
            $ck.Content = if ($langData -and $langData.$id -and $langData.$id.Content) {
                $langData.$id.Content
            } elseif ($base) { $base.Content } else { $_.Value.Content }
        }

        $tb = $sync["desc_$id"]
        if ($tb) {
            $tb.Text = if ($langData -and $langData.$id -and $langData.$id.Description) {
                $langData.$id.Description
            } elseif ($base) { $base.Description } else { $_.Value.Description }
        }
    }
}

function Invoke-FOMSwitchTab {
    param([string]$Category)
    $sync.currentTab = $Category

    # Swap content
    $sync.OptionsPanel.Children.Clear()
    if ($sync.fomPanels -and $sync.fomPanels[$Category]) {
        $sync.OptionsPanel.Children.Add($sync.fomPanels[$Category]) | Out-Null
    }

    # Highlight active nav button
    $tabOrder = @("Scanner","Processi","Input","Gaming","Sistema","Servizi","Power","Debloat","Personalizzazione","Avvio")
    foreach ($cat in $tabOrder) {
        $btn = $sync["NavBtn_$cat"]
        if (-not $btn) { continue }
        if ($cat -eq $Category) {
            $btn.Background  = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#1C2333")
            $btn.Foreground  = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#00C8FF")
            $btn.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#00C8FF")
        } else {
            $btn.Background  = [System.Windows.Media.BrushConverter]::new().ConvertFromString("Transparent")
            $btn.Foreground  = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#5A6A8A")
            $btn.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("Transparent")
        }
    }
}
