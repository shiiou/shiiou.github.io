# Charger les bibliotheques necessaires
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework

# Creer la fenetre principale
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Installation de Pack Graphique"
$Form.Size = New-Object System.Drawing.Size(500, 400)
$Form.StartPosition = "CenterScreen"
$Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$Form.MaximizeBox = $false
$Form.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48) # Couleur de fond sombre

# Titre de l'application
$LabelTitle = New-Object System.Windows.Forms.Label
$LabelTitle.Text = "Installation de Pack Graphique"
$LabelTitle.Font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
$LabelTitle.ForeColor = [System.Drawing.Color]::White
$LabelTitle.BackColor = [System.Drawing.Color]::Transparent
$LabelTitle.Location = New-Object System.Drawing.Point(20, 20)
$LabelTitle.AutoSize = $true
$Form.Controls.Add($LabelTitle)

# Fonction pour creer des boutons arrondis avec biseau
function Create-RoundedButton {
    param (
        [string]$Text,
        [int]$X,
        [int]$Y,
        [int]$Width,
        [int]$Height,
        [System.Drawing.Color]$BackColor,
        [System.Drawing.Color]$ForeColor
    )
    $Button = New-Object System.Windows.Forms.Button
    $Button.Text = $Text
    $Button.Location = New-Object System.Drawing.Point($X, $Y)
    $Button.Size = New-Object System.Drawing.Size($Width, $Height)
    $Button.BackColor = $BackColor
    $Button.ForeColor = $ForeColor
    $Button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $Button.FlatAppearance.BorderSize = 0
    $Button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(70, 70, 70)
    $Button.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)

    # Ajouter un effet biseau
    $Button.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(100, 100, 100)
    $Button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)

    # Ajouter des coins arrondis
    $Button.Region = [System.Drawing.Region]::FromHrgn((Create-RoundedRect 0, 0, $Width, $Height, 15))

    # Ajouter un effet de rebond (bounce) au survol
    $Button.Add_MouseEnter({
        $Button.Location = New-Object System.Drawing.Point($Button.Location.X, $Button.Location.Y - 5)
    })
    $Button.Add_MouseLeave({
        $Button.Location = New-Object System.Drawing.Point($Button.Location.X, $Button.Location.Y + 5)
    })

    return $Button
}

# Fonction pour creer des coins arrondis
function Create-RoundedRect {
    param (
        [int]$X,
        [int]$Y,
        [int]$Width,
        [int]$Height,
        [int]$CornerRadius
    )
    $Path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $Path.AddArc($X, $Y, $CornerRadius, $CornerRadius, 180, 90)
    $Path.AddArc($X + $Width - $CornerRadius, $Y, $CornerRadius, $CornerRadius, 270, 90)
    $Path.AddArc($X + $Width - $CornerRadius, $Y + $Height - $CornerRadius, $CornerRadius, $CornerRadius, 0, 90)
    $Path.AddArc($X, $Y + $Height - $CornerRadius, $CornerRadius, $CornerRadius, 90, 90)
    $Path.CloseFigure()
    return $Path
}

# Bouton pour selectionner GTA V
$ButtonGTAV = Create-RoundedButton -Text "Selectionner GTA V" -X 20 -Y 70 -Width 150 -Height 40 -BackColor ([System.Drawing.Color]::FromArgb(0, 120, 215)) -ForeColor ([System.Drawing.Color]::White)
$Form.Controls.Add($ButtonGTAV)

# Bouton pour selectionner FiveM
$ButtonFiveM = Create-RoundedButton -Text "Selectionner FiveM" -X 20 -Y 130 -Width 150 -Height 40 -BackColor ([System.Drawing.Color]::FromArgb(0, 120, 215)) -ForeColor ([System.Drawing.Color]::White)
$Form.Controls.Add($ButtonFiveM)

# Bouton pour selectionner le pack graphique
$ButtonPack = Create-RoundedButton -Text "Selectionner le Pack Graphique" -X 20 -Y 190 -Width 150 -Height 40 -BackColor ([System.Drawing.Color]::FromArgb(0, 120, 215)) -ForeColor ([System.Drawing.Color]::White)
$Form.Controls.Add($ButtonPack)

# Bouton pour installer le pack
$ButtonInstall = Create-RoundedButton -Text "Installer le Pack" -X 20 -Y 250 -Width 150 -Height 40 -BackColor ([System.Drawing.Color]::FromArgb(40, 167, 69)) -ForeColor ([System.Drawing.Color]::White)
$ButtonInstall.Enabled = $false
$Form.Controls.Add($ButtonInstall)

# Barre de progression
$ProgressBar = New-Object System.Windows.Forms.ProgressBar
$ProgressBar.Location = New-Object System.Drawing.Point(20, 310)
$ProgressBar.Size = New-Object System.Drawing.Size(440, 20)
$ProgressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
$ProgressBar.Visible = $false
$Form.Controls.Add($ProgressBar)

# Zone de texte pour afficher les chemins selectionnes
$TextBoxPaths = New-Object System.Windows.Forms.TextBox
$TextBoxPaths.Multiline = $true
$TextBoxPaths.Location = New-Object System.Drawing.Point(200, 70)
$TextBoxPaths.Size = New-Object System.Drawing.Size(260, 180)
$TextBoxPaths.ReadOnly = $true
$TextBoxPaths.BackColor = [System.Drawing.Color]::White
$Form.Controls.Add($TextBoxPaths)

# Variables pour stocker les chemins
$GTAVPath = $null
$FiveMPath = $null
$PackPath = $null

# Fonction pour selectionner un dossier
function Select-Folder {
    param (
        [string]$Description = "Selectionnez un dossier"
    )
    $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $FolderBrowser.Description = $Description
    if ($FolderBrowser.ShowDialog() -eq "OK") {
        return $FolderBrowser.SelectedPath
    } else {
        return $null
    }
}

# Evenement pour selectionner GTA V
$ButtonGTAV.Add_Click({
    $script:GTAVPath = Select-Folder -Description "Selectionnez le dossier de GTA V"
    if ($script:GTAVPath) {
        $TextBoxPaths.AppendText("GTA V : $script:GTAVPath`r`n")
    }
    Check-InstallButton
})

# Evenement pour selectionner FiveM
$ButtonFiveM.Add_Click({
    $script:FiveMPath = Select-Folder -Description "Selectionnez le dossier FiveM"
    if ($script:FiveMPath) {
        $TextBoxPaths.AppendText("FiveM : $script:FiveMPath`r`n")
    }
    Check-InstallButton
})

# Evenement pour selectionner le pack graphique
$ButtonPack.Add_Click({
    $script:PackPath = Select-Folder -Description "Selectionnez le dossier du pack graphique"
    if ($script:PackPath) {
        $TextBoxPaths.AppendText("Pack Graphique : $script:PackPath`r`n")
    }
    Check-InstallButton
})

# Fonction pour verifier si tous les chemins sont selectionnes
function Check-InstallButton {
    if ($script:GTAVPath -and $script:FiveMPath -and $script:PackPath) {
        $ButtonInstall.Enabled = $true
    } else {
        $ButtonInstall.Enabled = $false
    }
}

# Evenement pour installer le pack
$ButtonInstall.Add_Click({
    # Verifier que tous les chemins sont valides
    if (-not (Test-Path $script:GTAVPath) -or -not (Test-Path $script:FiveMPath) -or -not (Test-Path $script:PackPath)) {
        [System.Windows.Forms.MessageBox]::Show("Erreur : Un ou plusieurs chemins sont invalides.", "Erreur", "OK", "Error")
        return
    }

    # Afficher la barre de progression
    $ProgressBar.Visible = $true
    $ProgressBar.Value = 0

    # Chemin du dossier FiveM.app dans le pack
    $FiveMAppPath = Join-Path -Path $script:PackPath -ChildPath "FiveM.app"
    if (-not (Test-Path $FiveMAppPath)) {
        [System.Windows.Forms.MessageBox]::Show("Erreur : Dossier 'FiveM.app' introuvable dans le pack.", "Erreur", "OK", "Error")
        $ProgressBar.Visible = $false
        return
    }

    # Copier les dossiers "citizen", "mods" et "plugins" dans FiveM
    $FoldersToCopy = @("citizen", "mods", "plugins")
    $TotalSteps = $FoldersToCopy.Count + 1 # +1 pour le dossier GTA5
    $CurrentStep = 0

    foreach ($Folder in $FoldersToCopy) {
        $SourceFolder = Join-Path -Path $FiveMAppPath -ChildPath $Folder
        $DestinationFolder = Join-Path -Path $script:FiveMPath -ChildPath $Folder

        if (Test-Path $SourceFolder) {
            Copy-Item -Path $SourceFolder -Destination $DestinationFolder -Recurse -Force
        } else {
            [System.Windows.Forms.MessageBox]::Show("Erreur : Dossier '$Folder' introuvable dans le pack.", "Erreur", "OK", "Error")
            $ProgressBar.Visible = $false
            return
        }

        $CurrentStep++
        $ProgressBar.Value = ($CurrentStep / $TotalSteps) * 100
    }

    # Copier le contenu du dossier "GTA5" dans la racine de GTA V
    $GTAPackFolder = Join-Path -Path $script:PackPath -ChildPath "GTA5"
    if (Test-Path $GTAPackFolder) {
        $Files = Get-ChildItem -Path $GTAPackFolder -Recurse
        $TotalFiles = $Files.Count
        $CurrentFile = 0

        foreach ($File in $Files) {
            $Destination = $File.FullName.Replace($GTAPackFolder, $script:GTAVPath)
            $DestinationDir = [System.IO.Path]::GetDirectoryName($Destination)

            if (-not (Test-Path $DestinationDir)) {
                New-Item -ItemType Directory -Path $DestinationDir -Force | Out-Null
            }
            Copy-Item -Path $File.FullName -Destination $Destination -Force

            $CurrentFile++
            $ProgressBar.Value = (($CurrentStep + ($CurrentFile / $TotalFiles)) / $TotalSteps) * 100
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("Erreur : Dossier 'GTA5' introuvable dans le pack.", "Erreur", "OK", "Error")
        $ProgressBar.Visible = $false
        return
    }

    # Fin de l'installation
    $ProgressBar.Value = 100
    [System.Windows.Forms.MessageBox]::Show("Installation terminee avec succes !", "Succes", "OK", "Information")
    $ProgressBar.Visible = $false
})

# Afficher la fenetre
$Form.ShowDialog()