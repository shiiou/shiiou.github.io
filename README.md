# Shiiou — Portfolio photo et vidéo

Code complet du portfolio, prêt pour GitHub Pages. Les photos et vidéos sont hébergées séparément, par exemple sur Cloudinary. Aucun compte Cloudinary ni clé API n'est nécessaire pour les visiteurs.

## Publier sur GitHub Pages

1. Crée un dépôt **public** sur GitHub (par exemple `portfolio-shiiou`).
2. Téléverse **le contenu du dossier `dist`** à la racine du dépôt : `index.html`, `app.js`, `media.json` et `.nojekyll`. Ne téléverse pas le dossier `dist` lui-même.
3. Dans le dépôt, va dans **Settings → Pages → Build and deployment → Deploy from a branch**.
4. Sélectionne la branche `main`, le dossier `/ (root)`, puis **Save**. L'adresse sera `https://TON-IDENTIFIANT.github.io/portfolio-shiiou/` (ou `https://TON-IDENTIFIANT.github.io/` si le dépôt s'appelle `TON-IDENTIFIANT.github.io`).

## Ajouter des photos et des vidéos

1. Crée un compte gratuit sur [Cloudinary](https://cloudinary.com/), puis envoie les médias dans **Media Library**. Récupère chaque URL publique HTTPS (généralement `https://res.cloudinary.com/...`).
2. Modifie `media.json` à la racine de ton dépôt GitHub. Exemple :

```json
[
  {
    "type": "image",
    "title": "Portrait VRChat",
    "url": "https://res.cloudinary.com/VOTRE_CLOUD/image/upload/v1234/portrait.jpg"
  },
  {
    "type": "video",
    "title": "Showreel",
    "url": "https://res.cloudinary.com/VOTRE_CLOUD/video/upload/v1234/showreel.mp4",
    "thumbnail": "https://res.cloudinary.com/VOTRE_CLOUD/video/upload/so_1/v1234/showreel.jpg"
  }
]
```

Le champ `thumbnail` est facultatif. Il permet d'afficher une vignette de vidéo plus légère ; sans lui, le navigateur essaie de prévisualiser le fichier vidéo. Mets une virgule entre les objets, mais pas après le dernier. Après chaque modification sur GitHub, attends la mise à jour de GitHub Pages puis actualise le site.

**Ne mets jamais de clé API ni de secret Cloudinary dans ces fichiers.** Les URL publiques des médias sont visibles par tous, comme les images du portfolio. La formule gratuite Cloudinary a des quotas de stockage et de bande passante : vérifie les limites actuelles avant d'y placer une grande vidéothèque.

Pour tester localement, exécute `python -m http.server 8000` depuis le dossier `dist`, puis ouvre `http://localhost:8000`. Ouvrir `index.html` directement comme fichier local peut bloquer le chargement de `media.json`.
