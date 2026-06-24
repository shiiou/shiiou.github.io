# Solde — suivi de budget avec récap automatique Discord

## C'est quoi ?

Un petit serveur Node.js qui :
- sert le site web de suivi de dépenses
- stocke tout dans un fichier `data.json` sur le serveur (ça reste, ça ne dépend pas de ton navigateur)
- envoie automatiquement le récap hebdomadaire et mensuel sur Discord via cron, sans que tu aies besoin d'ouvrir le site

## Installation en local (pour tester avant de déployer)

1. Installe [Node.js](https://nodejs.org) si ce n'est pas déjà fait (version 18 ou plus)
2. Dans le dossier du projet :
   ```
   npm install
   ```
3. Copie `.env.example` en `.env` et remplis `DISCORD_WEBHOOK_URL` avec ton URL de webhook
   (Discord : Paramètres du salon → Intégrations → Webhooks → Nouveau webhook)
4. Lance le serveur :
   ```
   npm start
   ```
5. Ouvre `http://localhost:3000` dans ton navigateur

Tant que ton ordinateur est éteint, le cron ne tourne pas — pour que ça marche en permanence, il faut héberger ça quelque part qui reste allumé. Deux options simples ci-dessous.

## Déploiement — Option recommandée : Railway (gratuit pour ce type de petit projet)

1. Crée un compte sur [railway.app](https://railway.app)
2. Mets ce dossier dans un repo GitHub (privé si tu veux), ou utilise `railway up` en CLI directement depuis le dossier
3. Sur Railway : "New Project" → "Deploy from GitHub repo" (ou CLI)
4. Dans les "Variables" du projet Railway, ajoute :
   - `DISCORD_WEBHOOK_URL` = ton URL de webhook
   - (optionnel) `WEEKLY_CRON` et `MONTHLY_CHECK_CRON` si tu veux changer les horaires
5. Railway détecte automatiquement `npm start` et déploie
6. Tu obtiens une URL publique (ex: `solde.up.railway.app`) — c'est ton site, accessible depuis n'importe où, et le cron tourne en continu sur leurs serveurs

⚠️ Railway redémarre parfois le service (déploiements, maintenance). Le fichier `data.json` est stocké sur leur disque persistant par défaut sur le plan payant léger — sur le plan gratuit, vérifie l'option "volume" pour que `data.json` ne soit pas effacé à chaque redéploiement. Si tu veux zéro risque de perte de données, demande-moi et je peux brancher une vraie base de données (ex: Postgres gratuit sur Railway) à la place du fichier JSON.

## Déploiement — Alternative : un Raspberry Pi ou vieux PC chez toi

1. Installe Node.js sur la machine
2. Copie le dossier du projet dessus
3. `npm install` puis configure `.env`
4. Utilise `pm2` pour que ça tourne en permanence et redémarre si ça crash :
   ```
   npm install -g pm2
   pm2 start server.js --name solde
   pm2 save
   pm2 startup
   ```
5. Pour y accéder depuis l'extérieur, utilise un tunnel comme [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/) (gratuit) plutôt que d'ouvrir un port directement sur ta box

## Personnaliser les horaires d'envoi automatique

Dans `.env` :
- `WEEKLY_CRON=0 20 * * 0` → tous les dimanches à 20h00 (format cron standard : minute heure jour mois jour-semaine)
- `MONTHLY_CHECK_CRON=55 23 * * *` → vérifie tous les jours à 23h55 si c'est le dernier jour du mois, et envoie le récap mensuel si oui

## Structure du projet

```
budget-app/
├── server.js          → serveur Express + API + cron
├── package.json
├── .env.example        → à copier en .env
├── data.json           → créé automatiquement au premier lancement (tes données)
└── public/
    └── index.html      → le site (frontend)
```

## Sécurité

- Le fichier `.env` ne doit jamais être commité sur GitHub (ajoute-le à `.gitignore`)
- L'URL de ton webhook Discord donne le droit d'envoyer des messages dans ton salon — garde-la privée
- Ce projet n'a pas d'authentification : si tu déploies l'URL publiquement, n'importe qui avec le lien peut voir/modifier tes dépenses. Si ça t'inquiète, dis-le-moi et j'ajoute un mot de passe simple.
