#!/usr/bin/env bash
set -e

echo "🚀 GhostTrack‑v3 — UPGRADE COMPLETO UI (style + app.js + dashboard + about)"
echo

cd "$HOME/GhostTrack-v2" || { echo "❌ Repo non trovata"; exit 1; }
echo "📁 Root repo: $(pwd)"
echo

# 1) Proteggi file sensibili
echo "🔐 Aggiornamento .gitignore per file sensibili..."
touch .gitignore
grep -qxF ".eco_token" .gitignore || echo ".eco_token" >> .gitignore
grep -qxF "eco_log.py" .gitignore || echo "eco_log.py" >> .gitignore
echo "   ✔ File sensibili protetti"
echo

# 2) Assicura struttura cartelle UI
mkdir -p webapp/static/panels
echo "📂 Struttura webapp/static pronta"
echo

# 3) STYLE.CSS — stile completo, dark, professionale
echo "🎨 Aggiornamento webapp/static/style.css..."
cat > webapp/static/style.css << 'CSS'
:root {
  --bg: #050609;
  --bg-soft: #10131a;
  --bg-softer: #151826;
  --accent: #00eaff;
  --accent-soft: rgba(0, 234, 255, 0.12);
  --accent-strong: #46ffdf;
  --text: #e8edf7;
  --text-soft: #9ba4c4;
  --danger: #ff4b6b;
  --success: #46ff8a;
  --warning: #ffd35b;
  --border: #262b40;
  --shadow-soft: 0 12px 40px rgba(0, 0, 0, 0.6);
  --radius: 10px;
  --transition-fast: 0.15s ease-out;
}

* {
  box-sizing: border-box;
}

html, body {
  margin: 0;
  padding: 0;
  font-family: system-ui, -apple-system, BlinkMacSystemFont, "SF Pro Text", "Segoe UI", sans-serif;
  background: radial-gradient(circle at top, #151820 0, #050609 55%);
  color: var(--text);
  height: 100%;
}

#app {
  display: flex;
  min-height: 100vh;
}

/* SIDEBAR */

#sidebar {
  width: 260px;
  background: linear-gradient(180deg, #080a10 0, #050609 65%);
  border-right: 1px solid var(--border);
  padding: 18px 14px 18px 16px;
  display: flex;
  flex-direction: column;
  gap: 10px;
  box-shadow: var(--shadow-soft);
  position: sticky;
  top: 0;
  align-self: flex-start;
}

.logo {
  display: flex;
  align-items: center;
  gap: 10px;
  padding-bottom: 10px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.04);
  margin-bottom: 8px;
}

.logo-mark {
  width: 34px;
  height: 34px;
  border-radius: 10px;
  background: radial-gradient(circle at 30% 0, #ffffff 0, #00eaff 35%, #0066ff 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #050609;
  font-weight: 800;
  font-size: 18px;
  box-shadow: 0 0 18px rgba(0, 234, 255, 0.6);
}

.logo-text {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.logo-title {
  font-size: 17px;
  font-weight: 700;
  letter-spacing: 0.04em;
}

.logo-subtitle {
  font-size: 11px;
  text-transform: uppercase;
  color: var(--text-soft);
  letter-spacing: 0.16em;
}

#menu {
  display: flex;
  flex-direction: column;
  gap: 3px;
  margin-top: 4px;
}

.menu-title {
  font-size: 11px;
  text-transform: uppercase;
  letter-spacing: 0.14em;
  color: var(--text-soft);
  margin: 10px 8px 4px;
}

.menu-separator {
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
  margin: 10px 0 6px;
}

.menu-item {
  width: 100%;
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 7px 8px;
  background: transparent;
  border: none;
  border-radius: 7px;
  color: var(--text-soft);
  cursor: pointer;
  font-size: 13px;
  text-align: left;
  transition: background var(--transition-fast), color var(--transition-fast), transform 0.08s ease-out;
}

.menu-item .icon {
  width: 22px;
  display: flex;
  justify-content: center;
  font-size: 16px;
}

.menu-item .label {
  flex: 1;
  white-space: nowrap;
}

.menu-item:hover {
  background: rgba(255, 255, 255, 0.04);
  color: var(--text);
  transform: translateX(1px);
}

.menu-item.active {
  background: var(--accent-soft);
  color: var(--accent-strong);
  box-shadow: 0 0 0 1px rgba(0, 234, 255, 0.18);
}

/* MAIN */

#main {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

/* TOPBAR */

#topbar {
  height: 54px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
  border-bottom: 1px solid var(--border);
  background: linear-gradient(90deg, rgba(0, 234, 255, 0.06), transparent);
  backdrop-filter: blur(10px);
  position: sticky;
  top: 0;
  z-index: 10;
}

#topbar-title {
  font-size: 15px;
  font-weight: 600;
  letter-spacing: 0.06em;
  text-transform: uppercase;
}

#topbar-status {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  color: var(--text-soft);
}

.status-dot {
  width: 9px;
  height: 9px;
  border-radius: 50%;
  border: 1px solid rgba(0, 0, 0, 0.7);
  box-shadow: 0 0 0 2px rgba(0,0,0,0.4);
}

.status-dot.offline {
  background: var(--danger);
}

.status-dot.online {
  background: var(--success);
}

.status-dot.degraded {
  background: var(--warning);
}

/* PANEL CONTAINER */

#panel-container {
  padding: 18px 20px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.panel {
  background: var(--bg-soft);
  border-radius: var(--radius);
  border: 1px solid var(--border);
  padding: 16px 18px;
  box-shadow: var(--shadow-soft);
}

.panel h1, .panel h2, .panel h3 {
  margin-top: 0;
}

.panel h1 {
  font-size: 22px;
}

.panel h2 {
  font-size: 18px;
}

.panel .subtitle {
  font-size: 13px;
  color: var(--text-soft);
}

/* DASHBOARD GRID */

.dashboard-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 14px;
}

.card {
  background: var(--bg-softer);
  border-radius: var(--radius);
  padding: 12px 13px;
  border: 1px solid var(--border);
  box-shadow: 0 6px 18px rgba(0, 0, 0, 0.65);
}

.card-title {
  font-size: 13px;
  font-weight: 600;
  margin-bottom: 6px;
  display: flex;
  align-items: center;
  gap: 6px;
}

.card-metric {
  font-size: 22px;
  font-weight: 600;
  margin: 2px 0;
}

.card-sub {
  font-size: 11px;
  color: var(--text-soft);
}

.badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  font-size: 11px;
  padding: 2px 7px;
  border-radius: 999px;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.badge.success {
  border-color: var(--success);
  color: var(--success);
}

.badge.warning {
  border-color: var(--warning);
  color: var(--warning);
}

/* LINKS & BUTTONS IN PANELS */

.panel a {
  color: var(--accent-strong);
  text-decoration: none;
}

.panel a:hover {
  text-decoration: underline;
}

.button-inline {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 5px 9px;
  font-size: 12px;
  border-radius: 999px;
  border: 1px solid var(--border);
  background: rgba(255, 255, 255, 0.02);
  color: var(--text-soft);
  cursor: pointer;
  transition: background var(--transition-fast), color var(--transition-fast), border-color var(--transition-fast);
}

.button-inline:hover {
  background: var(--accent-soft);
  border-color: var(--accent);
  color: var(--accent-strong);
}

/* ABOUT PANEL */

.about-grid {
  display: grid;
  grid-template-columns: minmax(0, 2fr) minmax(0, 1.4fr);
  gap: 16px;
}

.about-block {
  background: var(--bg-softer);
  border-radius: var(--radius);
  padding: 12px 14px;
  border: 1px solid var(--border);
}

/* RESPONSIVE */

@media (max-width: 900px) {
  #sidebar {
    position: fixed;
    left: 0;
    top: 0;
    bottom: 0;
    z-index: 20;
  }

  #main {
    margin-left: 260px;
  }
}

@media (max-width: 700px) {
  #sidebar {
    display: none;
  }

  #main {
    margin-left: 0;
  }

  #topbar-title {
    font-size: 13px;
  }
}
CSS
echo "   ✔ style.css aggiornato"
echo

# 4) APP.JS — logica pannelli + DEV/PROD + status API
echo "🧠 Aggiornamento webapp/static/app.js..."
cat > webapp/static/app.js << 'JS'
const CONFIG_URL = "config.json";

let CONFIG = {
  mode: "dev",
  base_url_dev: "http://127.0.0.1:9090",
  base_url_prod: "https://example-api.ghosttrack.net"
};

let BASE_URL = CONFIG.base_url_dev;

// Carica config.json
async function loadConfig() {
  try {
    const res = await fetch(CONFIG_URL);
    if (!res.ok) return;
    const data = await res.json();
    CONFIG = { ...CONFIG, ...data };
    BASE_URL = CONFIG.mode === "prod" ? CONFIG.base_url_prod : CONFIG.base_url_dev;
  } catch (e) {
    console.warn("Impossibile caricare config.json, uso impostazioni default.", e);
  }
}

// Gestione status API
async function updateApiStatus() {
  const dot = document.getElementById("api-status-indicator");
  const text = document.getElementById("api-status-text");
  if (!dot || !text) return;

  dot.classList.remove("online", "offline", "degraded");
  dot.classList.add("offline");
  text.textContent = "API: in attesa…";

  try {
    const res = await fetch(`${BASE_URL}/api/status`, { cache: "no-store" });
    if (!res.ok) {
      dot.classList.remove("offline");
      dot.classList.add("degraded");
      text.textContent = `API: parziale (${res.status})`;
      return;
    }
    const data = await res.json().catch(() => ({}));
    dot.classList.remove("offline");
    dot.classList.add("online");

    const modeLabel = CONFIG.mode === "prod" ? "PROD" : "DEV";
    const ts = data.timestamp || "";
    text.textContent = `API: online (${modeLabel}) ${ts ? "— " + ts : ""}`;
  } catch (e) {
    dot.classList.remove("online", "degraded");
    dot.classList.add("offline");
    text.textContent = "API: offline";
  }
}

// Caricamento pannelli
async function loadPanel(panel) {
  const container = document.getElementById("panel-container");
  if (!container) return;
  container.innerHTML = `<div class="panel"><p>Caricamento pannello <b>${panel}</b>…</p></div>`;
  try {
    const res = await fetch(`panels/${panel}.html`);
    if (!res.ok) {
      container.innerHTML = `<div class="panel"><p>❌ Pannello <b>${panel}</b> non trovato.</p></div>`;
      return;
    }
    const html = await res.text();
    container.innerHTML = html;
  } catch (e) {
    container.innerHTML = `<div class="panel"><p>❌ Errore nel caricamento del pannello <b>${panel}</b>.</p></div>`;
  }
}

// Caricamento domini (futuro: index per dominio, per ora solo messaggio)
async function loadDomain(domain) {
  const container = document.getElementById("panel-container");
  if (!container) return;
  container.innerHTML = `
    <div class="panel">
      <h2>Domina: ${domain}</h2>
      <p class="subtitle">Pannelli per questo dominio sono disponibili in <code>webapp/static/panels/${domain}/</code>.</p>
      <p>Seleziona un modulo dalla costellazione o apri i pannelli direttamente.</p>
    </div>
  `;
}

// Gestione menu
function setupMenu() {
  const menu = document.getElementById("menu");
  if (!menu) return;

  menu.addEventListener("click", (ev) => {
    const btn = ev.target.closest("button.menu-item");
    if (!btn) return;

    const panel = btn.getAttribute("data-panel");
    const domain = btn.getAttribute("data-domain");

    // Active state
    document.querySelectorAll("#menu .menu-item").forEach(b => b.classList.remove("active"));
    btn.classList.add("active");

    if (panel) loadPanel(panel);
    if (domain) loadDomain(domain);
  });

  // Seleziona dashboard di default
  const first = menu.querySelector('button.menu-item[data-panel="dashboard"]');
  if (first) {
    first.classList.add("active");
    loadPanel("dashboard");
  }
}

// Inizializzazione
(async function init() {
  await loadConfig();
  setupMenu();
  updateApiStatus();
  setInterval(updateApiStatus, 15000);
})();
JS
echo "   ✔ app.js aggiornato"
echo

# 5) DASHBOARD.HTML — pannello principale arricchito
echo "📊 Aggiornamento webapp/static/panels/dashboard.html..."
cat > webapp/static/panels/dashboard.html << 'HTML'
<div class="panel">
  <h1>📡 GhostTrack‑v3 — Dashboard Nodo</h1>
  <p class="subtitle">
    Stato rapido del nodo di osservazione, crediti energetici e accesso ai domini principali.
  </p>

  <div class="dashboard-grid" style="margin-top: 12px;">
    <div class="card">
      <div class="card-title">
        <span>API / Telemetria Nodo</span>
        <span class="badge success" id="dash-api-mode">--</span>
      </div>
      <div class="card-metric" id="dash-api-status">In attesa…</div>
      <div class="card-sub" id="dash-api-ts">Nessun dato ancora.</div>
    </div>

    <div class="card">
      <div class="card-title">
        <span>Crediti energetici</span>
        <span class="badge">Wallet</span>
      </div>
      <div class="card-metric" id="dash-credits-total">--</div>
      <div class="card-sub" id="dash-credits-delta">Variazione 24h: --</div>
      <button class="button-inline" onclick="loadPanel('wallet')">
        💳 Apri pannello Wallet
      </button>
    </div>

    <div class="card">
      <div class="card-title">
        <span>Media & Live</span>
        <span class="badge warning">Red Bull TV</span>
      </div>
      <div class="card-sub">
        Sessioni media possono essere collegate al wallet crediti per simulare consumo/ricarica energetica.
      </div>
      <button class="button-inline" onclick="loadPanel('media_live')">
        🎥 Apri pannello Media & Live
      </button>
    </div>

    <div class="card">
      <div class="card-title">
        <span>Documentazione</span>
        <span class="badge">Wiki</span>
      </div>
      <div class="card-sub">
        Accedi alla documentazione tecnica, all'executive report, alla roadmap e alla pagina About direttamente dal menu.
      </div>
      <button class="button-inline" onclick="window.open('docs/INDEX.md','_blank')">
        📘 Apri Documentazione Tecnica
      </button>
    </div>
  </div>
</div>

<script>
// Mini hook per aggiornare i widget dashboard in base allo status API
(function syncDashboardStatus() {
  const textEl = document.getElementById("api-status-text");
  const dotEl = document.getElementById("api-status-indicator");
  const dashStatus = document.getElementById("dash-api-status");
  const dashTs = document.getElementById("dash-api-ts");
  const dashMode = document.getElementById("dash-api-mode");

  if (!textEl || !dashStatus || !dashMode) return;

  setTimeout(() => {
    dashStatus.textContent = textEl.textContent.replace("API: ", "");
    if (dotEl && dotEl.classList.contains("online")) {
      dashMode.textContent = "Online";
    } else if (dotEl && dotEl.classList.contains("degraded")) {
      dashMode.textContent = "Degradato";
    } else {
      dashMode.textContent = "Offline";
    }
    // Timestamp se presente nel testo
    const parts = textEl.textContent.split("—");
    if (parts.length > 1) {
      dashTs.textContent = "Ultimo aggiornamento " + parts[1].trim();
    }
  }, 600);
})();
</script>
HTML
echo "   ✔ dashboard.html aggiornato"
echo

# 6) ABOUT PANEL — pannello About integrato nella UI
echo "ℹ️ Aggiornamento webapp/static/panels/about.html..."
cat > webapp/static/panels/about.html << 'HTML'
<div class="panel">
  <h1>ℹ️ GhostTrack‑v2 / v3 — About Nodo</h1>
  <p class="subtitle">
    Nodo di osservazione etico, modulare, progettato per sperimentazione, ricerca e divulgazione tecnica.
  </p>

  <div class="about-grid" style="margin-top: 14px;">
    <div class="about-block">
      <h3>🌍 Missione</h3>
      <p>
        GhostTrack nasce per esplorare territorio, ambiente, reti e segnali in modo responsabile,
        trasformando ogni nodo in un laboratorio vivente.
      </p>
      <p>
        Il focus è su osservazione etica, resilienza, sperimentazione e uso educativo: scuole, laboratori,
        makers, ricercatori e chiunque voglia un contesto reale per imparare.
      </p>
    </div>

    <div class="about-block">
      <h3>🧭 Domini funzionali</h3>
      <p>
        La costellazione copre 18 domini: CyberDefense, Orbital & Space, Agro & Ambiente,
        Calcolo & Ricerca, Radio & SDR, Anonimato & Routing, Reti & Mesh, Performance,
        Sistema Core, Moduli Estesi, Media & Live, Chat & Feed, Mappe & Atlas,
        Resilienza & Emergenza, Storage, Osservazione, AI & Analisi, Sperimentazione.
      </p>
      <p>
        Ogni dominio ha pannelli dedicati nella WebApp e una sezione nella documentazione ufficiale.
      </p>
    </div>

    <div class="about-block">
      <h3>📘 Documentazione & Executive</h3>
      <p>
        La documentazione tecnica, l'executive report e la roadmap sono disponibili come file Markdown
        nella cartella <code>docs/</code> e sono accessibili direttamente dal menu.
      </p>
      <p>
        Sono pensati per lettura da parte di enti, partner, auditor, ma anche come guida
        per chi entra nel progetto per la prima volta.
      </p>
    </div>

    <div class="about-block">
      <h3>🛡 Etica e limiti</h3>
      <p>
        GhostTrack è orientato a osservazione ambientale, scientifica e infrastrutturale.
        Non è progettato né pensato per sorveglianza personale o violazione della privacy.
      </p>
      <p>
        Ogni nodo dovrebbe essere configurato nel rispetto delle leggi locali e dei principi etici
        definiti nella documentazione del progetto.
      </p>
    </div>
  </div>
</div>
HTML
echo "   ✔ about.html aggiornato"
echo

# 7) Aggiungi a Git
echo "📦 Aggiunta file UI a Git..."
git add webapp/static/style.css webapp/static/app.js webapp/static/panels/dashboard.html webapp/static/panels/about.html 2>/dev/null || true
echo "   ✔ File UI aggiunti allo staging"
echo

# 8) Commit (se ci sono modifiche)
if git diff --cached --quiet; then
  echo "ℹ️ Nessuna modifica da committare (UI già allineata)."
else
  echo "📝 Creazione commit UI..."
  git commit -m "UI GhostTrack‑v3: nuovo style.css, app.js, dashboard e pannello About"
  echo "   ✔ Commit creato"
fi
echo

# 9) Push
echo "🌍 Push su GitHub..."
git push
echo "   ✔ Push completato"
echo

echo "✨ UI GhostTrack‑v3 aggiornata e pubblicata (style + app.js + dashboard + about)."
