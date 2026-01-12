#!/usr/bin/env bash
set -e

echo "🔧 Costruzione UI GhostTrack reale..."

# 1. Struttura cartelle
mkdir -p webapp/static/panels

# 2. config.json (reale, nessuna simulazione)
cat > webapp/static/config.json <<'JSON'
{
  "version": "3.0",
  "environment": "production",

  "api": {
    "base_url": "http://127.0.0.1:9090",
    "timeout_ms": 8000
  },

  "ui": {
    "theme": "dark",
    "menu_mode": "expanded",
    "icons": true,
    "animations": true
  },

  "modules": {
    "dashboard": true,
    "economist": true,
    "orchestrator": true,
    "wallet": true,
    "podcast_liberi": true,
    "starlink_control": true,
    "settings": true
  },

  "starlink": {
    "mode": "real",
    "credits_model": "hybrid",
    "telemetry_interval_sec": 5,
    "map_enabled": true,
    "realtime_graph": true,
    "satellite_predictions": true
  },

  "podcast": {
    "allow_custom_streams": true,
    "default_streams": [
      {
        "name": "SomaFM Groove Salad",
        "url": "https://ice2.somafm.com/groovesalad-128-mp3"
      },
      {
        "name": "Radio Paradise",
        "url": "https://stream.radioparadise.com/aac-320"
      }
    ]
  }
}
JSON

# 3. index.html (shell SPA reale)
cat > webapp/static/index.html <<'HTML'
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="utf-8">
  <title>GhostTrack WebApp</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="icon" href="favicon.ico" type="image/x-icon">
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <div id="app">
    <aside id="sidebar">
      <div class="logo">
        <div class="logo-mark">G</div>
        <div class="logo-text">
          <div class="logo-title">GhostTrack</div>
          <div class="logo-subtitle">Operational Console</div>
        </div>
      </div>
      <nav id="menu">
        <button class="menu-item" data-panel="dashboard">
          <span class="icon">📡</span><span class="label">Dashboard</span>
        </button>
        <button class="menu-item" data-panel="economist">
          <span class="icon">📈</span><span class="label">Economist</span>
        </button>
        <button class="menu-item" data-panel="orchestrator">
          <span class="icon">🧭</span><span class="label">Orchestrator</span>
        </button>
        <button class="menu-item" data-panel="wallet">
          <span class="icon">💳</span><span class="label">Wallet</span>
        </button>
        <button class="menu-item" data-panel="podcast_liberi">
          <span class="icon">🎵</span><span class="label">Podcast liberi</span>
        </button>
        <button class="menu-item" data-panel="starlink_control">
          <span class="icon">🛰️</span><span class="label">Starlink Control</span>
        </button>
        <div class="menu-separator"></div>
        <button class="menu-item" data-panel="settings">
          <span class="icon">⚙️</span><span class="label">Impostazioni</span>
        </button>
      </nav>
    </aside>
    <main id="main">
      <header id="topbar">
        <div id="topbar-title">GhostTrack Console</div>
        <div id="topbar-status">
          <span id="api-status-indicator" class="status-dot offline"></span>
          <span id="api-status-text">API: sconosciuto</span>
        </div>
      </header>
      <section id="panel-container">
        <!-- I pannelli vengono caricati dinamicamente -->
      </section>
    </main>
  </div>
  <script type="module" src="app.js"></script>
</body>
</html>
HTML

# 4. style.css (dark, menu espanso con icone)
cat > webapp/static/style.css <<'CSS'
:root {
  --bg-main: #050509;
  --bg-sidebar: #0b0b10;
  --bg-panel: #111119;
  --accent: #e33939;
  --accent-soft: #ff5c5c33;
  --text-primary: #eeeeee;
  --text-secondary: #9a9ab3;
  --border-soft: #262638;
  --success: #26d07c;
  --warning: #ffb347;
  --danger: #ff4d4d;
  --font-main: system-ui, -apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif;
}

*,
*::before,
*::after {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  background: radial-gradient(circle at top left, #151520 0, #050509 45%, #000000 100%);
  color: var(--text-primary);
  font-family: var(--font-main);
  height: 100vh;
  overflow: hidden;
}

#app {
  display: flex;
  height: 100vh;
  width: 100vw;
}

/* Sidebar */

#sidebar {
  width: 280px;
  background: linear-gradient(180deg, #0f0f17 0%, #050509 100%);
  border-right: 1px solid var(--border-soft);
  display: flex;
  flex-direction: column;
  padding: 16px 14px;
}

.logo {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 8px 6px 16px;
  border-bottom: 1px solid #1b1b2a;
  margin-bottom: 12px;
}

.logo-mark {
  width: 32px;
  height: 32px;
  border-radius: 999px;
  background: radial-gradient(circle at 30% 20%, #ff6b6b 0, #e33939 40%, #5c0a0a 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 18px;
}

.logo-text {
  display: flex;
  flex-direction: column;
}

.logo-title {
  font-weight: 600;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  font-size: 13px;
}

.logo-subtitle {
  font-size: 11px;
  color: var(--text-secondary);
}

/* Menu */

#menu {
  margin-top: 8px;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.menu-item {
  width: 100%;
  display: flex;
  align-items: center;
  gap: 10px;
  border: none;
  background: transparent;
  color: var(--text-secondary);
  padding: 8px 10px;
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
  transition: background 0.15s ease, color 0.15s ease, transform 0.08s ease;
}

.menu-item .icon {
  width: 26px;
  text-align: center;
  font-size: 18px;
}

.menu-item .label {
  flex: 1;
  text-align: left;
}

.menu-item:hover {
  background: #181824;
  color: var(--text-primary);
  transform: translateX(1px);
}

.menu-item.active {
  background: var(--accent-soft);
  color: var(--text-primary);
  border: 1px solid var(--accent);
}

.menu-separator {
  height: 1px;
  margin: 8px 0;
  background: #1b1b2a;
}

/* Main */

#main {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: radial-gradient(circle at top center, #26263a 0, #050509 50%, #000000 100%);
}

/* Topbar */

#topbar {
  height: 52px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 18px;
  border-bottom: 1px solid var(--border-soft);
  background: linear-gradient(90deg, #111119 0, #090914 100%);
}

#topbar-title {
  font-size: 15px;
  font-weight: 500;
  letter-spacing: 0.06em;
  text-transform: uppercase;
}

#topbar-status {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  color: var(--text-secondary);
}

.status-dot {
  width: 9px;
  height: 9px;
  border-radius: 999px;
  border: 1px solid #000;
}

.status-dot.offline {
  background: var(--danger);
}

.status-dot.online {
  background: var(--success);
}

/* Panel container */

#panel-container {
  flex: 1;
  padding: 16px 18px;
  overflow: auto;
}

/* Card / Panel base */

.panel {
  background: var(--bg-panel);
  border-radius: 14px;
  border: 1px solid var(--border-soft);
  padding: 14px 16px;
  box-shadow: 0 14px 40px #000000a0;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.panel-title {
  font-size: 15px;
  font-weight: 500;
}

.panel-subtitle {
  font-size: 12px;
  color: var(--text-secondary);
}

.panel-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 12px;
  margin-top: 10px;
}

.stat-card {
  background: #161621;
  border-radius: 10px;
  border: 1px solid #25253a;
  padding: 10px 12px;
}

.stat-label {
  font-size: 11px;
  color: var(--text-secondary);
}

.stat-value {
  font-size: 17px;
  margin-top: 4px;
}

.stat-extra {
  font-size: 11px;
  margin-top: 4px;
  color: var(--text-secondary);
}

/* Podcast panel */

.podcast-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-top: 10px;
}

.podcast-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #14141f;
  border-radius: 8px;
  border: 1px solid #23233a;
  padding: 8px 10px;
}

.podcast-meta {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.podcast-name {
  font-size: 13px;
}

.podcast-url {
  font-size: 11px;
  color: var(--text-secondary);
}

.podcast-actions button {
  font-size: 11px;
  padding: 4px 8px;
  border-radius: 999px;
  border: 1px solid var(--accent);
  background: var(--accent-soft);
  color: var(--text-primary);
  cursor: pointer;
}

/* Starlink panel */

.starlink-layout {
  display: grid;
  grid-template-columns: minmax(0, 2.2fr) minmax(0, 1.4fr);
  gap: 12px;
  margin-top: 10px;
}

.starlink-subpanel {
  background: #14141f;
  border-radius: 10px;
  border: 1px solid #23233a;
  padding: 10px 12px;
}

.starlink-subtitle {
  font-size: 12px;
  color: var(--text-secondary);
  margin-bottom: 6px;
}

.starlink-map,
.starlink-chart {
  width: 100%;
  height: 200px;
  border-radius: 8px;
  background: radial-gradient(circle at top, #20203a 0, #090913 60%, #050509 100%);
  border: 1px solid #26263a;
}

/* Settings */

.settings-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-top: 10px;
}

.settings-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #14141f;
  border-radius: 8px;
  border: 1px solid #23233a;
  padding: 8px 10px;
  font-size: 13px;
}

.toggle {
  position: relative;
  width: 38px;
  height: 20px;
  border-radius: 999px;
  background: #303047;
  cursor: pointer;
}

.toggle-knob {
  position: absolute;
  width: 16px;
  height: 16px;
  border-radius: 999px;
  background: #ffffff;
  top: 2px;
  left: 2px;
  transition: transform 0.15s ease;
}

.toggle.on {
  background: var(--accent);
}

.toggle.on .toggle-knob {
  transform: translateX(18px);
}

/* Responsive */

@media (max-width: 768px) {
  #sidebar {
    width: 230px;
  }
}
CSS

# 5. app.js (router, loader config, pannelli, chiamate reali)
cat > webapp/static/app.js <<'JS'
async function loadConfig() {
  const res = await fetch('config.json');
  if (!res.ok) throw new Error('Config non accessibile');
  return res.json();
}

let CONFIG = null;
let CURRENT_PANEL = null;
let API_STATUS_INTERVAL = null;

async function checkApiStatus() {
  const indicator = document.getElementById('api-status-indicator');
  const text = document.getElementById('api-status-text');
  try {
    const res = await fetch(CONFIG.api.base_url + '/api/status', {
      method: 'GET',
      headers: { 'Accept': 'application/json' }
    });
    if (!res.ok) throw new Error('HTTP ' + res.status);
    const data = await res.json();
    indicator.classList.remove('offline');
    indicator.classList.add('online');
    text.textContent = `API: online (${data.version || 'v3'})`;
  } catch (err) {
    indicator.classList.remove('online');
    indicator.classList.add('offline');
    text.textContent = 'API: offline';
  }
}

function setActiveMenu(panelId) {
  document.querySelectorAll('.menu-item').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.panel === panelId);
  });
  CURRENT_PANEL = panelId;
}

async function loadPanel(panelId) {
  const container = document.getElementById('panel-container');
  setActiveMenu(panelId);

  const panelPath = `panels/${panelId}.html`;
  try {
    const res = await fetch(panelPath);
    if (!res.ok) throw new Error('Pannello non trovato');
    const html = await res.text();
    container.innerHTML = html;
    if (panelId === 'starlink_control') {
      initStarlinkPanel();
    } else if (panelId === 'podcast_liberi') {
      initPodcastPanel();
    }
  } catch (err) {
    container.innerHTML = `
      <div class="panel">
        <div class="panel-header">
          <div class="panel-title">Errore</div>
        </div>
        <p>Impossibile caricare il pannello <code>${panelId}</code>.</p>
      </div>`;
  }
}

function initMenu() {
  document.querySelectorAll('.menu-item').forEach(btn => {
    btn.addEventListener('click', () => {
      const target = btn.dataset.panel;
      loadPanel(target);
    });
  });
}

function initPodcastPanel() {
  const container = document.querySelector('.podcast-list');
  const audio = document.getElementById('podcast-player');
  const currentLabel = document.getElementById('podcast-current');

  container.innerHTML = '';

  CONFIG.podcast.default_streams.forEach(stream => {
    const item = document.createElement('div');
    item.className = 'podcast-item';
    item.innerHTML = `
      <div class="podcast-meta">
        <div class="podcast-name">${stream.name}</div>
        <div class="podcast-url">${stream.url}</div>
      </div>
      <div class="podcast-actions">
        <button data-url="${stream.url}">Ascolta</button>
      </div>
    `;
    item.querySelector('button').addEventListener('click', () => {
      audio.src = stream.url;
      audio.play().catch(() => {});
      currentLabel.textContent = stream.name;
    });
    container.appendChild(item);
  });
}

function initStarlinkPanel() {
  const refreshBtn = document.getElementById('starlink-refresh');
  const modeBoostBtn = document.getElementById('starlink-mode-boost');
  const modeSaveBtn = document.getElementById('starlink-mode-save');

  refreshBtn.addEventListener('click', () => {
    fetchStarlinkStatus();
  });

  modeBoostBtn.addEventListener('click', () => {
    // Chiamata reale: endpoint da implementare lato API
    // fetch(CONFIG.api.base_url + '/api/starlink/boost', { method: 'POST' });
  });

  modeSaveBtn.addEventListener('click', () => {
    // Chiamata reale: endpoint da implementare lato API
    // fetch(CONFIG.api.base_url + '/api/starlink/power_save', { method: 'POST' });
  });

  fetchStarlinkStatus();
}

async function fetchStarlinkStatus() {
  const latencyEl = document.getElementById('starlink-latency');
  const dlEl = document.getElementById('starlink-download');
  const ulEl = document.getElementById('starlink-upload');
  const uptimeEl = document.getElementById('starlink-uptime');
  const creditsEl = document.getElementById('starlink-credits');
  const modeEl = document.getElementById('starlink-mode');

  try {
    const res = await fetch(CONFIG.api.base_url + '/api/starlink/status', {
      headers: { 'Accept': 'application/json' }
    });
    if (!res.ok) throw new Error('HTTP ' + res.status);
    const data = await res.json();
    latencyEl.textContent = (data.latency_ms ?? '-') + ' ms';
    dlEl.textContent = (data.download_mbps ?? '-') + ' Mbps';
    ulEl.textContent = (data.upload_mbps ?? '-') + ' Mbps';
    uptimeEl.textContent = (data.uptime_h ?? '-') + ' h';
    creditsEl.textContent = data.credits ?? '-';
    modeEl.textContent = data.mode ?? 'unknown';
  } catch {
    latencyEl.textContent = '-';
    dlEl.textContent = '-';
    ulEl.textContent = '-';
    uptimeEl.textContent = '-';
    creditsEl.textContent = '-';
    modeEl.textContent = 'offline';
  }
}

async function main() {
  CONFIG = await loadConfig();
  initMenu();
  if (API_STATUS_INTERVAL) clearInterval(API_STATUS_INTERVAL);
  await checkApiStatus();
  API_STATUS_INTERVAL = setInterval(checkApiStatus, 8000);
  loadPanel('dashboard');
}

main().catch(err => {
  const container = document.getElementById('panel-container');
  container.innerHTML = `
    <div class="panel">
      <div class="panel-header">
        <div class="panel-title">Errore critico</div>
      </div>
      <p>Impossibile inizializzare la console: ${err.message}</p>
    </div>`;
});
JS

# 6. Pannelli HTML

# dashboard
cat > webapp/static/panels/dashboard.html <<'HTML'
<div class="panel">
  <div class="panel-header">
    <div>
      <div class="panel-title">Dashboard</div>
      <div class="panel-subtitle">Stato complessivo della costellazione GhostTrack</div>
    </div>
  </div>
  <div class="panel-grid">
    <div class="stat-card">
      <div class="stat-label">Stato API</div>
      <div class="stat-value" id="dash-api-status">Vedi barra in alto</div>
      <div class="stat-extra">Monitoraggio continuo dell'endpoint /api/status</div>
    </div>
    <div class="stat-card">
      <div class="stat-label">Modulo Starlink</div>
      <div class="stat-value">Attivo</div>
      <div class="stat-extra">Controllo e crediti energetici ibridi</div>
    </div>
    <div class="stat-card">
      <div class="stat-label">Podcast liberi</div>
      <div class="stat-value">Pronto</div>
      <div class="stat-extra">Ascolto diretto dalla console</div>
    </div>
  </div>
</div>
HTML

# economist
cat > webapp/static/panels/economist.html <<'HTML'
<div class="panel">
  <div class="panel-header">
    <div>
      <div class="panel-title">Economist</div>
      <div class="panel-subtitle">Analisi dei crediti energetici GhostTrack</div>
    </div>
  </div>
  <div class="panel-grid">
    <div class="stat-card">
      <div class="stat-label">Crediti totali</div>
      <div class="stat-value" id="eco-total-credits">-</div>
      <div class="stat-extra">Totale accumulato dalla costellazione</div>
    </div>
    <div class="stat-card">
      <div class="stat-label">Crediti odierni</div>
      <div class="stat-value" id="eco-today-credits">-</div>
      <div class="stat-extra">Basati su uptime, banda e stabilità</div>
    </div>
    <div class="stat-card">
      <div class="stat-label">Bonus Starlink</div>
      <div class="stat-value" id="eco-starlink-bonus">-</div>
      <div class="stat-extra">Incremento dovuto alla qualità del link Starlink</div>
    </div>
  </div>
</div>
HTML

# orchestrator
cat > webapp/static/panels/orchestrator.html <<'HTML'
<div class="panel">
  <div class="panel-header">
    <div>
      <div class="panel-title">Orchestrator</div>
      <div class="panel-subtitle">Coordinamento dei moduli e dei nodi GhostTrack</div>
    </div>
  </div>
  <p>Qui potrai governare lo stato operativo dei moduli, la sincronizzazione e la salute complessiva della costellazione.</p>
</div>
HTML

# wallet
cat > webapp/static/panels/wallet.html <<'HTML'
<div class="panel">
  <div class="panel-header">
    <div>
      <div class="panel-title">Wallet</div>
      <div class="panel-subtitle">Portafoglio crediti energetici GhostTrack</div>
    </div>
  </div>
  <div class="panel-grid">
    <div class="stat-card">
      <div class="stat-label">Saldo</div>
      <div class="stat-value" id="wallet-balance">-</div>
      <div class="stat-extra">Crediti disponibili</div>
    </div>
    <div class="stat-card">
      <div class="stat-label">Ultima transazione</div>
      <div class="stat-value" id="wallet-last-tx">-</div>
      <div class="stat-extra">Agganciabile a /api/wallet</div>
    </div>
  </div>
</div>
HTML

# podcast
cat > webapp/static/panels/podcast_liberi.html <<'HTML'
<div class="panel">
  <div class="panel-header">
    <div>
      <div class="panel-title">Podcast liberi</div>
      <div class="panel-subtitle">Ascolto di musica e stream liberi dalla console</div>
    </div>
  </div>
  <audio id="podcast-player" controls style="width:100%; margin-top:8px;">
    Il tuo browser non supporta l'audio HTML5.
  </audio>
  <div style="margin-top:6px; font-size:11px; color:#9a9ab3;">
    Corrente: <span id="podcast-current">nessuno</span>
  </div>
  <div class="podcast-list"></div>
</div>
HTML

# starlink
cat > webapp/static/panels/starlink_control.html <<'HTML'
<div class="panel">
  <div class="panel-header">
    <div>
      <div class="panel-title">Starlink Control</div>
      <div class="panel-subtitle">Telemetria reale, mappa ed energia ibrida</div>
    </div>
    <div style="display:flex; gap:6px;">
      <button id="starlink-refresh" class="podcast-actions-button">Aggiorna</button>
      <button id="starlink-mode-boost" class="podcast-actions-button">Boost</button>
      <button id="starlink-mode-save" class="podcast-actions-button">Power Save</button>
    </div>
  </div>
  <div class="starlink-layout">
    <div class="starlink-subpanel">
      <div class="starlink-subtitle">Telemetria link</div>
      <div class="panel-grid">
        <div class="stat-card">
          <div class="stat-label">Latenza</div>
          <div class="stat-value" id="starlink-latency">-</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Download</div>
          <div class="stat-value" id="starlink-download">-</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Upload</div>
          <div class="stat-value" id="starlink-upload">-</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Uptime</div>
          <div class="stat-value" id="starlink-uptime">-</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Crediti energetici</div>
          <div class="stat-value" id="starlink-credits">-</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Modalità</div>
          <div class="stat-value" id="starlink-mode">-</div>
        </div>
      </div>
    </div>
    <div class="starlink-subpanel">
      <div class="starlink-subtitle">Mappa costellazione e previsioni</div>
      <div class="starlink-map" id="starlink-map"></div>
      <div style="margin-top:8px; font-size:11px; color:#9a9ab3;">
        Agganciabile a dati TLE reali e previsioni di visibilità satelliti.
      </div>
    </div>
  </div>
</div>
HTML

# settings
cat > webapp/static/panels/settings.html <<'HTML'
<div class="panel">
  <div class="panel-header">
    <div>
      <div class="panel-title">Impostazioni</div>
      <div class="panel-subtitle">Preferenze console GhostTrack</div>
    </div>
  </div>
  <div class="settings-list">
    <div class="settings-item">
      <span>Tema</span>
      <span>Dark (fisso)</span>
    </div>
    <div class="settings-item">
      <span>Menu</span>
      <span>Espanso con icone</span>
    </div>
  </div>
</div>
HTML

echo "✨ UI GhostTrack creata in webapp/static/"
