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
