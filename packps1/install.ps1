# Definition des chemins d'installation
$downloadPath = "$env:USERPROFILE\Downloads"
$packZip = "SHIIOU V2.zip"
$extractPath = "$downloadPath\SHIIOU V2"

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
}

# Fonction pour afficher un message en couleur
function Write-ColorMessage {
    param (
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Affichage des consignes pour l'utilisateur
Write-BoxedMessage "Instructions pour l'installation" -Color Cyan
Write-ColorMessage "1. Telechargez le pack graphique en cliquant sur le lien ci-dessous :" -Color Cyan
Write-Host "-> [Telecharger le pack $packZip](https://drive.google.com/uc?export=download&id=186sHyZiJyXW0Ox89v0CpqBkL366FRa33)" -ForegroundColor Blue
Write-ColorMessage "2. Placez le fichier '$packZip' dans votre dossier Downloads : $downloadPath" -Color Yellow
Write-ColorMessage "3. Appuyez sur une touche pour continuer une fois que le fichier est place dans le dossier Downloads..." -Color Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Verification du fichier ZIP dans le dossier Downloads
Write-BoxedMessage "Verification du fichier ZIP" -Color Cyan
$destinationZip = "$downloadPath\$packZip"

if (Test-Path -Path $destinationZip) {
    Write-ColorMessage "Fichier ZIP trouve : $destinationZip" -Color Green
} else {
    Write-ColorMessage "Impossible de localiser $packZip dans $downloadPath. Verifiez son emplacement." -Color Red
    exit
}

# Extraction du fichier ZIP
Write-BoxedMessage "Extraction du fichier ZIP" -Color Cyan
if (!(Test-Path -Path $extractPath)) {
    New-Item -ItemType Directory -Path $extractPath -Force | Out-Null
}
Expand-Archive -Path $destinationZip -DestinationPath $extractPath -Force
Write-ColorMessage "Fichier ZIP extrait dans : $extractPath" -Color Green

# Recherche du dossier FiveM.app sur tous les disques
Write-BoxedMessage "Recherche du dossier FiveM.app" -Color Cyan
$fivemPath = Get-ChildItem -Path C:\,D:\,E:\ -Recurse -Directory -Filter "FiveM.app" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName

if ($fivemPath) {
    Write-ColorMessage "Dossier FiveM.app trouve : $fivemPath" -Color Green
} else {
    Write-ColorMessage "Impossible de localiser le dossier 'FiveM.app'. Verifiez votre installation." -Color Red
    exit
}

# Copie des dossiers FiveM (citizen, mods, plugins) depuis le pack SHIIOU V2
Write-BoxedMessage "Installation des fichiers FiveM" -Color Cyan
$foldersToCopy = @("citizen", "mods", "plugins")
foreach ($folder in $foldersToCopy) {
    $source = "$extractPath\$folder"
    $destination = "$fivemPath\$folder"
    if (Test-Path -Path $source) {
        Remove-Item -Path $destination -Recurse -Force -ErrorAction SilentlyContinue
        Copy-Item -Path $source -Destination $destination -Recurse -Force
        Write-ColorMessage "Remplace : $folder -> $destination" -Color Green
    } else {
        Write-ColorMessage "Dossier introuvable : $source" -Color Yellow
    }
}

# Recherche du dossier "Grand Theft Auto V" sur tous les disques
Write-BoxedMessage "Recherche du dossier Grand Theft Auto V" -Color Cyan
$gta5Path = Get-ChildItem -Path C:\,D:\,E:\ -Recurse -Directory -Filter "Grand Theft Auto V" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName

if ($gta5Path) {
    Write-ColorMessage "Dossier Grand Theft Auto V trouve : $gta5Path" -Color Green
} else {
    Write-ColorMessage "Impossible de localiser le dossier 'Grand Theft Auto V'. Verifiez son emplacement." -Color Red
    exit
}

# Copie des fichiers du pack graphique vers le dossier GTA V
Write-BoxedMessage "Installation des fichiers graphiques dans GTA V" -Color Cyan
if (Test-Path -Path "$extractPath\Grand Theft Auto V") {
    $gta5Source = "$extractPath\Grand Theft Auto V"
    Remove-Item -Path "$gta5Path\*" -Recurse -Force -ErrorAction SilentlyContinue
    Copy-Item -Path "$gta5Source\*" -Destination "$gta5Path" -Recurse -Force
    Write-ColorMessage "Fichiers graphiques installes et remplaces avec succes dans GTA V !" -Color Green
} else {
    Write-ColorMessage "Le dossier 'Grand Theft Auto V' est introuvable dans le pack SHIIOU V2." -Color Red
}

# Message de fin
Write-BoxedMessage "Installation terminee" -Color Green
