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
