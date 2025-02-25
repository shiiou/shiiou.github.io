# Definition des chemins d'installation
$fivemPath = "$env:LOCALAPPDATA\FiveM\FiveM.app"
$gtaFilesSource = "$PSScriptRoot\Grand Theft Auto V"
$packZip = "SHIIOU V2.zip"

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

# Verification et creation du repertoire FiveM si necessaire
Write-BoxedMessage "Verification de l'installation de FiveM" -Color Cyan
if (!(Test-Path -Path $fivemPath)) {
    Write-ColorMessage "Le dossier FiveM n'existe pas. Verifiez votre installation." -Color Red
    exit
} else {
    Write-ColorMessage "Dossier FiveM trouve : $fivemPath" -Color Green
}

# Affichage du lien cliquable pour telecharger le pack
Write-BoxedMessage "Telechargement du pack graphique" -Color Cyan
Write-ColorMessage "Veuillez telecharger le pack graphique en cliquant sur le lien ci-dessous :" -Color Cyan
Write-Host "-> [Telecharger le pack $packZip](https://drive.google.com/uc?export=download&id=186sHyZiJyXW0Ox89v0CpqBkL366FRa33)" -ForegroundColor Blue
Write-ColorMessage "Une fois le telechargement termine, placez le fichier '$packZip' dans le dossier TEMP ($env:TEMP)." -Color Yellow
Write-ColorMessage "Appuyez sur une touche pour continuer apres avoir telecharge et place le fichier..." -Color Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Recherche du pack telecharge dans le dossier TEMP
Write-BoxedMessage "Recherche du pack graphique" -Color Cyan
$destinationZip = "$env:TEMP\$packZip"

if (Test-Path -Path $destinationZip) {
    Write-ColorMessage "Pack trouve : $destinationZip" -Color Green
} else {
    Write-ColorMessage "Impossible de localiser $packZip dans $env:TEMP. Verifiez son emplacement." -Color Red
    exit
}

# Extraction du pack et remplacement des fichiers si necessaire
Write-BoxedMessage "Extraction du pack graphique" -Color Cyan
$extractPath = "$env:TEMP\SHIIOU_V2_Extracted"
if (!(Test-Path -Path $extractPath)) {
    New-Item -ItemType Directory -Path $extractPath -Force | Out-Null
}
Expand-Archive -Path $destinationZip -DestinationPath $extractPath -Force
Write-ColorMessage "Pack extrait dans : $extractPath" -Color Green

# Copie des dossiers FiveM avec remplacement
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

# Detection du dossier GTA 5 en recherchant "Grand Theft Auto V"
Write-BoxedMessage "Recherche du repertoire GTA 5" -Color Cyan
$gta5Path = Get-ChildItem -Path C:\,D:\,E:\ -Directory -Filter "Grand Theft Auto V" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName

if ($gta5Path) {
    Write-ColorMessage "Dossier GTA 5 trouve dans : $gta5Path" -Color Green
} else {
    Write-ColorMessage "Impossible de localiser le dossier 'Grand Theft Auto V'. Verifiez son emplacement." -Color Red
    exit
}

# Copie des fichiers du pack graphique vers le dossier de GTA 5 avec remplacement
Write-BoxedMessage "Installation des fichiers graphiques dans GTA 5" -Color Cyan
if (Test-Path -Path $extractPath) {
    Remove-Item -Path "$gta5Path\*" -Recurse -Force -ErrorAction SilentlyContinue
    Copy-Item -Path "$extractPath\*" -Destination "$gta5Path" -Recurse -Force
    Write-ColorMessage "Fichiers graphiques installes et remplaces avec succes !" -Color Green
} else {
    Write-ColorMessage "Le dossier source du pack extrait est introuvable." -Color Red
}

# Message de fin
Write-BoxedMessage "Installation terminee" -Color Green
