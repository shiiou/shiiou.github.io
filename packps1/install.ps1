# Definition des chemins d'installation
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

# Verification du dossier FiveM.app
Write-BoxedMessage "Verification du dossier FiveM.app" -Color Cyan
if (Test-Path -Path $fivemPath) {
    Write-ColorMessage "Dossier FiveM.app trouve : $fivemPath" -Color Green
} else {
    Write-ColorMessage "Impossible de localiser le dossier 'FiveM.app'. Verifiez votre installation." -Color Red
    exit
}

# Copie des dossiers FiveM (citizen, mods, plugins) depuis le pack SHIIOU V2
Write-BoxedMessage "Installation des fichiers FiveM" -Color Cyan
$foldersToCopy = @("citizen", "mods", "plugins")
foreach ($folder in $foldersToCopy) {
    $source = "$extractPath\SHIIOU V2\SHIIOU V2\$folder"
    $destination = "$fivemPath\$folder"
    if (Test-Path -Path $source) {
        Remove-Item -Path $destination -Recurse -Force -ErrorAction SilentlyContinue
        Copy-Item -Path $source -Destination $destination -Recurse -Force
        Write-ColorMessage "Remplace : $folder -> $destination" -Color Green
    } else {
        Write-ColorMessage "Dossier introuvable : $source" -Color Yellow
    }
}

# Recherche du dossier "Grand Theft Auto V" dans le pack SHIIOU V2
Write-BoxedMessage "Recherche du dossier Grand Theft Auto V dans le pack" -Color Cyan
$gta5Source = "$extractPath\SHIIOU V2\SHIIOU V2\Grand Theft Auto V"

if (Test-Path -Path $gta5Source) {
    Write-ColorMessage "Dossier Grand Theft Auto V trouve dans le pack : $gta5Source" -Color Green
} else {
    Write-ColorMessage "Impossible de localiser le dossier 'Grand Theft Auto V' dans le pack SHIIOU V2." -Color Red
    exit
}

# Recherche du dossier "Grand Theft Auto V" sur tous les disques
Write-BoxedMessage "Recherche du dossier Grand Theft Auto V sur l'ordinateur" -Color Cyan
$gta5Path = Get-ChildItem -Path C:\,D:\,E:\ -Recurse -Directory -Filter "Grand Theft Auto V" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName

if ($gta5Path) {
    Write-ColorMessage "Dossier Grand Theft Auto V trouve sur l'ordinateur : $gta5Path" -Color Green
} else {
    Write-ColorMessage "Impossible de localiser le dossier 'Grand Theft Auto V'. Verifiez son emplacement." -Color Red
    exit
}

# Copie des fichiers du pack graphique vers le dossier GTA V
Write-BoxedMessage "Installation des fichiers graphiques dans GTA V" -Color Cyan
Remove-Item -Path "$gta5Path\*" -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item -Path "$gta5Source\*" -Destination "$gta5Path" -Recurse -Force
Write-ColorMessage "Fichiers graphiques installes et remplaces avec succes dans GTA V !" -Color Green

# Message de fin
Write-BoxedMessage "Installation terminee" -Color Green
