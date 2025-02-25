# Définition des chemins d'installation
$fivemPath = "$env:LOCALAPPDATA\FiveM\FiveM.app"
$gtaFilesSource = "$PSScriptRoot\Grand Theft Auto V"
$packZip = "SHIIOU V2.zip"

# Fonction pour afficher un message en couleur
function Write-ColorMessage {
    param (
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Vérification et création du répertoire FiveM si nécessaire
if (!(Test-Path -Path $fivemPath)) {
    Write-ColorMessage "Le dossier FiveM n'existe pas. Vérifiez votre installation." -Color Red
    exit
}

# Affichage du lien cliquable pour télécharger le pack
Write-ColorMessage "Veuillez télécharger le pack graphique en cliquant sur le lien ci-dessous :" -Color Cyan
Write-Host "-> [Télécharger le pack $packZip](https://drive.google.com/uc?export=download&id=186sHyZiJyXW0Ox89v0CpqBkL366FRa33)" -ForegroundColor Blue
Write-ColorMessage "Une fois le téléchargement terminé, placez le fichier '$packZip' dans le dossier TEMP ($env:TEMP)." -Color Yellow
Write-ColorMessage "Appuyez sur une touche pour continuer après avoir téléchargé et placé le fichier..." -Color Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Recherche du pack téléchargé dans le dossier TEMP
Write-ColorMessage "Recherche du fichier $packZip dans $env:TEMP..." -Color Cyan
$destinationZip = "$env:TEMP\$packZip"

if (Test-Path -Path $destinationZip) {
    Write-ColorMessage "Pack trouvé: $destinationZip" -Color Green
} else {
    Write-ColorMessage "Impossible de localiser $packZip dans $env:TEMP. Vérifiez son emplacement." -Color Red
    exit
}

# Extraction du pack et remplacement des fichiers si nécessaire
Write-ColorMessage "Extraction du pack $packZip..." -Color Cyan
$extractPath = "$env:TEMP\SHIIOU_V2_Extracted"
if (!(Test-Path -Path $extractPath)) {
    New-Item -ItemType Directory -Path $extractPath -Force | Out-Null
}
Expand-Archive -Path $destinationZip -DestinationPath $extractPath -Force

# Copie des dossiers FiveM avec remplacement
Write-ColorMessage "Installation des fichiers FiveM..." -Color Cyan
$foldersToCopy = @("citizen", "mods", "plugins")
foreach ($folder in $foldersToCopy) {
    $source = "$extractPath\$folder"
    $destination = "$fivemPath\$folder"
    if (Test-Path -Path $source) {
        Remove-Item -Path $destination -Recurse -Force -ErrorAction SilentlyContinue
        Copy-Item -Path $source -Destination $destination -Recurse -Force
        Write-ColorMessage "Remplacé: $folder -> $destination" -Color Green
    } else {
        Write-ColorMessage "Dossier introuvable: $source" -Color Yellow
    }
}

# Détection du dossier GTA 5 en recherchant "Grand Theft Auto V"
Write-ColorMessage "Recherche du répertoire GTA 5..." -Color Cyan
$gta5Path = Get-ChildItem -Path C:\,D:\,E:\ -Directory -Filter "Grand Theft Auto V" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName

if ($gta5Path) {
    Write-ColorMessage "Dossier GTA 5 trouvé dans: $gta5Path" -Color Green
} else {
    Write-ColorMessage "Impossible de localiser le dossier 'Grand Theft Auto V'. Vérifiez son emplacement." -Color Red
    exit
}

# Copie des fichiers du pack graphique vers le dossier de GTA 5 avec remplacement
Write-ColorMessage "Installation des fichiers graphiques dans GTA 5..." -Color Cyan
if (Test-Path -Path $extractPath) {
    Remove-Item -Path "$gta5Path\*" -Recurse -Force -ErrorAction SilentlyContinue
    Copy-Item -Path "$extractPath\*" -Destination "$gta5Path" -Recurse -Force
    Write-ColorMessage "Fichiers graphiques installés et remplacés avec succès !" -Color Green
} else {
    Write-ColorMessage "Le dossier source du pack extrait est introuvable." -Color Red
}

Write-ColorMessage "Installation terminée." -Color Cyan
