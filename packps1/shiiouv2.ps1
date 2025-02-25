# Définition des chemins d'installation
$downloadPath = "$env:USERPROFILE\Downloads"
$packZip = "SHIIOU V2.zip"
$extractPath = "$downloadPath\SHIIOU_V2_Extracted"
$fivemPath = "$env:LOCALAPPDATA\FiveM\FiveM.app"

# Fonction pour afficher un message en couleur avec une bordure
function Write-BoxedMessage {
    param (
        [string]$Message,
        [string]$Color = "White"
    )
    $border = "=" * ($Message.Length + 4)
    Write-Host $border -ForegroundColor $Color
    Write-Host "| $Message |" -ForegroundColor $Color
    Write-Host $border -ForegroundColor $Color
    Write-Host ""  # Ligne vide pour l'espacement
}

# Fonction pour afficher un message en couleur
function Write-ColorMessage {
    param (
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
    Write-Host ""  # Ligne vide pour l'espacement
}

# Affichage des consignes pour l'utilisateur
Write-BoxedMessage "Installation du pack SHIIOU V2" -Color Cyan
Write-ColorMessage "1. Téléchargez le pack graphique avant de faire cette manipulation en cliquant sur le lien ci-dessous :" -Color Cyan
Write-Host "-> [Télécharger le pack $packZip](https://drive.google.com/uc?export=download&id=186sHyZiJyXW0Ox89v0CpqBkL366FRa33)" -ForegroundColor Blue
Write-ColorMessage "2. Placez le fichier '$packZip' dans votre dossier Téléchargements : $downloadPath" -Color Yellow
Write-ColorMessage "3. Appuyez sur une touche pour continuer une fois que le fichier est placé dans le dossier Téléchargements..." -Color Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host ""  # Ligne vide pour l'espacement

# Vérification du fichier ZIP dans le dossier Téléchargements
Write-BoxedMessage "Vérification du fichier ZIP" -Color Cyan
$destinationZip = "$downloadPath\$packZip"

if (Test-Path -Path $destinationZip) {
    Write-ColorMessage "SHIIOU : $destinationZip" -Color Green
} else {
    Write-ColorMessage "Impossible de localiser $packZip dans $downloadPath. Vérifiez son emplacement." -Color Red
    exit
}
Write-Host ""  # Ligne vide pour l'espacement

# Extraction du fichier ZIP
Write-BoxedMessage "Extraction du fichier ZIP" -Color Cyan
if (!(Test-Path -Path $extractPath)) {
    New-Item -ItemType Directory -Path $extractPath -Force | Out-Null
}
Expand-Archive -Path $destinationZip -DestinationPath $extractPath -Force
Write-ColorMessage "SHIIOU : $extractPath" -Color Green
Write-Host ""  # Ligne vide pour l'espacement

# Vérification du dossier FiveM.app
Write-BoxedMessage "Vérification du dossier FiveM.app" -Color Cyan
if (Test-Path -Path $fivemPath) {
    Write-ColorMessage "Dossier FiveM.app trouvé : $fivemPath" -Color Green
} else {
    Write-ColorMessage "Impossible de localiser le dossier 'FiveM.app'. Vérifiez votre installation." -Color Red
    exit
}
Write-Host ""  # Ligne vide pour l'espacement

# Copie des dossiers FiveM (citizen, mods, plugins) depuis le pack SHIIOU V2
Write-BoxedMessage "Installation des fichiers FiveM" -Color Cyan
$foldersToCopy = @("citizen", "mods", "plugins")
foreach ($folder in $foldersToCopy) {
    $source = "$extractPath\SHIIOU V2\FiveM.app\$folder"
    $destination = "$fivemPath\$folder"
    if (Test-Path -Path $source) {
        Copy-Item -Path "$source\*" -Destination $destination -Recurse -Force
        Write-ColorMessage "Installé : $folder -> $destination" -Color Green
    } else {
        Write-ColorMessage "Dossier introuvable : $source" -Color Yellow
    }
}
Write-Host ""  # Ligne vide pour l'espacement

# Recherche du dossier "Grand Theft Auto V" dans le pack SHIIOU V2
Write-BoxedMessage "Vérification du dossier GTA5" -Color Cyan
$gta5Source = "$extractPath\SHIIOU V2\GTA5"

if (Test-Path -Path $gta5Source) {
    Write-ColorMessage "SHIIOU : $gta5Source" -Color Green
} else {
    Write-ColorMessage "Impossible de localiser le dossier 'Grand Theft Auto V' dans le pack SHIIOU V2." -Color Red
    exit
}
Write-Host ""  # Ligne vide pour l'espacement

# Recherche du dossier "Grand Theft Auto V" sur tous les disques
Write-BoxedMessage "Recherche du dossier du jeu Grand Theft Auto V" -Color Cyan
$gta5Path = Get-ChildItem -Path C:\,D:\,E:\ -Recurse -Directory -Filter "Grand Theft Auto V" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName

if ($gta5Path) {
    Write-ColorMessage "SHIIOU : $gta5Path" -Color Green
} else {
    Write-ColorMessage "Impossible de localiser le dossier 'Grand Theft Auto V'. Vérifiez son emplacement." -Color Red
    exit
}
Write-Host ""  # Ligne vide pour l'espacement

# Copie des fichiers du pack graphique vers le dossier GTA V (sans suppression)
Write-BoxedMessage "Installation des fichiers GTA5" -Color Cyan
Copy-Item -Path "$gta5Source\*" -Destination "$gta5Path" -Recurse -Force
Write-ColorMessage "Installé avec succès dans GTA V !" -Color Green
Write-Host ""  # Ligne vide pour l'espacement

# Message de fin
Write-BoxedMessage "Merci d'avoir installé le pack Shiiou V2" -Color Red
