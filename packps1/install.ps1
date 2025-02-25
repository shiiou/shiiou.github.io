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
$destinationZip = "$PSScriptRoot\$packZip"
Invoke-WebRequest -Uri $downloadUrl -OutFile $destinationZip

# Extraction du pack
Write-Host "Extraction du pack $packZip..." -ForegroundColor Cyan
Expand-Archive -Path $destinationZip -DestinationPath $PSScriptRoot -Force

# Copie des dossiers FiveM
Write-Host "Installation des fichiers FiveM..." -ForegroundColor Cyan
$foldersToCopy = @("citizen", "mods", "plugins")
foreach ($folder in $foldersToCopy) {
    $source = "$PSScriptRoot\$folder"
    $destination = "$fivemPath\$folder"
    if (Test-Path -Path $source) {
        Copy-Item -Path $source -Destination $destination -Recurse -Force
        Write-Host "Copié: $folder -> $destination" -ForegroundColor Green
    } else {
        Write-Host "Dossier introuvable: $source" -ForegroundColor Yellow
    }
}

# Détection du dossier GTA 5 en recherchant GTA5.exe
Write-Host "Recherche du répertoire GTA 5..." -ForegroundColor Cyan
$gta5Path = Get-ChildItem -Path C:\,D:\,E:\ -Recurse -Filter "GTA5.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty DirectoryName

if ($gta5Path) {
    Write-Host "GTA 5 trouvé dans: $gta5Path" -ForegroundColor Green
} else {
    Write-Host "Impossible de localiser GTA5.exe. Vérifiez son emplacement." -ForegroundColor Red
    exit
}

# Copie des fichiers du pack graphique vers le dossier de GTA 5
Write-Host "Installation des fichiers graphiques dans GTA 5..." -ForegroundColor Cyan
if (Test-Path -Path $gtaFilesSource) {
    Copy-Item -Path "$gtaFilesSource\*" -Destination "$gta5Path" -Recurse -Force
    Write-Host "Fichiers graphiques installés avec succès !" -ForegroundColor Green
} else {
    Write-Host "Le dossier source Grand Theft Auto V est introuvable." -ForegroundColor Red
}

Write-Host "Installation terminée." -ForegroundColor Cyan
