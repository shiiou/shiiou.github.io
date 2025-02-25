# Définition des chemins d'installation
$fivemPath = "$env:LOCALAPPDATA\FiveM\FiveM.app"
$gtaFilesSource = "$PSScriptRoot\Grand Theft Auto V"
$packZip = "SHIIOU V2.zip"

# Vérification et création du répertoire FiveM si nécessaire
if (!(Test-Path -Path $fivemPath)) {
    Write-Host "Le dossier FiveM n'existe pas. Vérifiez votre installation." -ForegroundColor Red
    exit
}

# Téléchargement du pack graphique
Write-Host "Téléchargement du pack $packZip..." -ForegroundColor Cyan
$downloadUrl = "https://drive.google.com/uc?export=download&id=186sHyZiJyXW0Ox89v0CpqBkL366FRa33"
$destinationZip = "$env:TEMP\$packZip"
Invoke-WebRequest -Uri $downloadUrl -OutFile $destinationZip

# Recherche du pack téléchargé dans tous les dossiers
Write-Host "Recherche du fichier $packZip..." -ForegroundColor Cyan
$foundZip = Get-ChildItem -Path C:\,D:\,E:\ -Recurse -Filter "$packZip" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName

if ($foundZip) {
    Write-Host "Pack trouvé: $foundZip" -ForegroundColor Green
    $destinationZip = $foundZip
} else {
    Write-Host "Impossible de localiser $packZip. Vérifiez son emplacement." -ForegroundColor Red
    exit
}

# Extraction du pack et remplacement des fichiers si nécessaire
Write-Host "Extraction du pack $packZip..." -ForegroundColor Cyan
$extractPath = "$env:TEMP\SHIIOU_V2_Extracted"
if (!(Test-Path -Path $extractPath)) {
    New-Item -ItemType Directory -Path $extractPath -Force | Out-Null
}
Expand-Archive -Path $destinationZip -DestinationPath $extractPath -Force

# Copie des dossiers FiveM avec remplacement
Write-Host "Installation des fichiers FiveM..." -ForegroundColor Cyan
$foldersToCopy = @("citizen", "mods", "plugins")
foreach ($folder in $foldersToCopy) {
    $source = "$extractPath\$folder"
    $destination = "$fivemPath\$folder"
    if (Test-Path -Path $source) {
        Remove-Item -Path $destination -Recurse -Force -ErrorAction SilentlyContinue
        Copy-Item -Path $source -Destination $destination -Recurse -Force
        Write-Host "Remplacé: $folder -> $destination" -ForegroundColor Green
    } else {
        Write-Host "Dossier introuvable: $source" -ForegroundColor Yellow
    }
}

# Détection du dossier GTA 5 en recherchant "Grand Theft Auto V"
Write-Host "Recherche du répertoire GTA 5..." -ForegroundColor Cyan
$gta5Path = Get-ChildItem -Path C:\,D:\,E:\ -Directory -Filter "Grand Theft Auto V" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName

if ($gta5Path) {
    Write-Host "Dossier GTA 5 trouvé dans: $gta5Path" -ForegroundColor Green
} else {
    Write-Host "Impossible de localiser le dossier 'Grand Theft Auto V'. Vérifiez son emplacement." -ForegroundColor Red
    exit
}

# Copie des fichiers du pack graphique vers le dossier de GTA 5 avec remplacement
Write-Host "Installation des fichiers graphiques dans GTA 5..." -ForegroundColor Cyan
if (Test-Path -Path $extractPath) {
    Remove-Item -Path "$gta5Path\*" -Recurse -Force -ErrorAction SilentlyContinue
    Copy-Item -Path "$extractPath\*" -Destination "$gta5Path" -Recurse -Force
    Write-Host "Fichiers graphiques installés et remplacés avec succès !" -ForegroundColor Green
} else {
    Write-Host "Le dossier source du pack extrait est introuvable." -ForegroundColor Red
}

Write-Host "Installation terminée." -ForegroundColor Cyan
