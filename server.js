require('dotenv').config();
const express = require('express');
const fs = require('fs');
const path = require('path');
const cron = require('node-cron');
const fetch = require('node-fetch');

const app = express();
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

const DATA_FILE = path.join(__dirname, 'data.json');
const PORT = process.env.PORT || 3000;

// ---------- Stockage sur fichier ----------

function loadData() {
  if (!fs.existsSync(DATA_FILE)) {
    const initial = {
      incomeAmount: parseFloat(process.env.INCOME_AMOUNT) || 110,
      webhookUrl: process.env.DISCORD_WEBHOOK_URL || '',
      transactions: [],
      incomeEvents: []
    };
    fs.writeFileSync(DATA_FILE, JSON.stringify(initial, null, 2));
    return initial;
  }
  const data = JSON.parse(fs.readFileSync(DATA_FILE, 'utf-8'));
  // migration douce si un ancien fichier sans incomeEvents existe encore
  if (!data.incomeEvents) data.incomeEvents = [];
  if (typeof data.incomeAmount !== 'number') data.incomeAmount = parseFloat(process.env.INCOME_AMOUNT) || 110;
  return data;
}

function saveData(data) {
  fs.writeFileSync(DATA_FILE, JSON.stringify(data, null, 2));
}

// ---------- Aides de dates ----------

function getISOWeekKey(d) {
  const date = new Date(d);
  date.setHours(0, 0, 0, 0);
  date.setDate(date.getDate() + 3 - ((date.getDay() + 6) % 7));
  const week1 = new Date(date.getFullYear(), 0, 4);
  const weekNum = 1 + Math.round(((date - week1) / 86400000 - 3 + ((week1.getDay() + 6) % 7)) / 7);
  return date.getFullYear() + '-W' + String(weekNum).padStart(2, '0');
}
function getMonthKey(d) {
  const date = new Date(d);
  return date.getFullYear() + '-' + String(date.getMonth() + 1).padStart(2, '0');
}
function startOfWeek(d) {
  const date = new Date(d);
  const day = (date.getDay() + 6) % 7;
  date.setDate(date.getDate() - day);
  date.setHours(0, 0, 0, 0);
  return date;
}
function fmt(n) {
  return n.toLocaleString('fr-FR', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + ' €';
}
function weekIncomeTotal(data, now) {
  const weekKey = getISOWeekKey(now || new Date());
  return data.incomeEvents
    .filter(ev => getISOWeekKey(ev.date) === weekKey)
    .reduce((s, ev) => s + ev.amount, 0);
}
function isLastDayOfMonth(d) {
  const date = new Date(d);
  const tomorrow = new Date(date);
  tomorrow.setDate(date.getDate() + 1);
  return tomorrow.getDate() === 1;
}

// ---------- Construction des messages ----------

function buildWeeklyMessage(data) {
  const now = new Date();
  const weekKey = getISOWeekKey(now);
  const weekTx = data.transactions.filter(t => getISOWeekKey(t.date) === weekKey);
  const spent = weekTx.reduce((s, t) => s + t.amount, 0);
  const income = weekIncomeTotal(data, now);
  const left = income - spent;
  const lines = weekTx
    .sort((a, b) => new Date(a.date) - new Date(b.date))
    .map(t => `• ${t.description} — ${fmt(t.amount)} (${t.category})`)
    .join('\n') || '_Aucune dépense_';
  const statusLine = left < 0 ? `⚠️ Dans le rouge de ${fmt(Math.abs(left))}` : `✅ Reste ${fmt(left)}`;
  return `**📋 Récap hebdomadaire — semaine du ${startOfWeek(now).toLocaleDateString('fr-FR')}**\nRevenu reçu : ${fmt(income)}\nDépensé : ${fmt(spent)}\n${statusLine}\n\n${lines}`;
}

function buildMonthlyMessage(data) {
  const now = new Date();
  const monthKey = getMonthKey(now);
  const monthTx = data.transactions.filter(t => getMonthKey(t.date) === monthKey);
  const spent = monthTx.reduce((s, t) => s + t.amount, 0);
  const byCat = {};
  monthTx.forEach(t => byCat[t.category] = (byCat[t.category] || 0) + t.amount);
  const lines = Object.entries(byCat)
    .sort((a, b) => b[1] - a[1])
    .map(([cat, amt]) => `• ${cat} — ${fmt(amt)}`)
    .join('\n') || '_Aucune dépense_';
  const monthName = now.toLocaleDateString('fr-FR', { month: 'long', year: 'numeric' });
  return `**📅 Récap mensuel — ${monthName}**\nTotal dépensé : ${fmt(spent)}\n\nPar catégorie :\n${lines}`;
}

async function sendToDiscord(webhookUrl, content) {
  if (!webhookUrl) throw new Error('Pas de webhook configuré');
  const res = await fetch(webhookUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ content })
  });
  if (!res.ok && res.status !== 204) {
    throw new Error('Discord a refusé la requête : ' + res.status);
  }
}

// ---------- Routes API ----------

app.get('/api/data', (req, res) => {
  const data = loadData();
  res.json({ ...data, currentWeekIncome: weekIncomeTotal(data) });
});

app.post('/api/transactions', (req, res) => {
  const { description, amount, category } = req.body;
  if (!description || typeof amount !== 'number' || amount <= 0 || !category) {
    return res.status(400).json({ error: 'Champs invalides' });
  }
  const data = loadData();
  data.transactions.push({
    id: Date.now().toString(36) + Math.random().toString(36).slice(2, 7),
    date: new Date().toISOString(),
    description,
    amount,
    category
  });
  saveData(data);
  res.json({ ...data, currentWeekIncome: weekIncomeTotal(data) });
});

app.delete('/api/transactions/:id', (req, res) => {
  const data = loadData();
  data.transactions = data.transactions.filter(t => t.id !== req.params.id);
  saveData(data);
  res.json({ ...data, currentWeekIncome: weekIncomeTotal(data) });
});

app.post('/api/settings', (req, res) => {
  const { incomeAmount, webhookUrl } = req.body;
  const data = loadData();
  data.incomeAmount = typeof incomeAmount === 'number' ? incomeAmount : data.incomeAmount;
  data.webhookUrl = typeof webhookUrl === 'string' ? webhookUrl : data.webhookUrl;
  saveData(data);
  res.json({ ...data, currentWeekIncome: weekIncomeTotal(data) });
});

app.post('/api/send-recap/week', async (req, res) => {
  const data = loadData();
  try {
    await sendToDiscord(data.webhookUrl, buildWeeklyMessage(data));
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ ok: false, error: e.message });
  }
});

app.post('/api/send-recap/month', async (req, res) => {
  const data = loadData();
  try {
    await sendToDiscord(data.webhookUrl, buildMonthlyMessage(data));
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ ok: false, error: e.message });
  }
});

// ---------- Cron automatique ----------

const weeklyCron = process.env.WEEKLY_CRON || '0 20 * * 0'; // dimanche 20h par défaut
const monthlyCheckCron = process.env.MONTHLY_CHECK_CRON || '55 23 * * *'; // vérifie tous les jours à 23h55
const incomeCron = process.env.INCOME_CRON || '0 9 * * 2'; // mardi 9h par défaut

cron.schedule(incomeCron, async () => {
  const data = loadData();
  const amount = data.incomeAmount;
  data.incomeEvents.push({
    id: Date.now().toString(36) + Math.random().toString(36).slice(2, 7),
    date: new Date().toISOString(),
    amount
  });
  saveData(data);
  console.log(`[cron] Versement automatique de ${fmt(amount)} crédité`);
  try {
    await sendToDiscord(data.webhookUrl, `💶 Versement automatique reçu : **${fmt(amount)}**`);
  } catch (e) {
    console.error('[cron] Échec notification versement :', e.message);
  }
});

cron.schedule(weeklyCron, async () => {
  const data = loadData();
  try {
    await sendToDiscord(data.webhookUrl, buildWeeklyMessage(data));
    console.log('[cron] Récap hebdomadaire envoyé');
  } catch (e) {
    console.error('[cron] Échec envoi récap hebdomadaire :', e.message);
  }
});

cron.schedule(monthlyCheckCron, async () => {
  if (!isLastDayOfMonth(new Date())) return;
  const data = loadData();
  try {
    await sendToDiscord(data.webhookUrl, buildMonthlyMessage(data));
    console.log('[cron] Récap mensuel envoyé');
  } catch (e) {
    console.error('[cron] Échec envoi récap mensuel :', e.message);
  }
});

app.listen(PORT, () => {
  console.log(`Serveur lancé sur http://localhost:${PORT}`);
  console.log(`Versement automatique : "${incomeCron}" (mardi 9h par défaut, ${process.env.INCOME_AMOUNT || 110}€)`);
  console.log(`Récap hebdo automatique : "${weeklyCron}"`);
  console.log(`Vérification récap mensuel : "${monthlyCheckCron}" (envoi le dernier jour du mois)`);
});
