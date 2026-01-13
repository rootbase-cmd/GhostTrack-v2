#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

log() {
  printf "\n[GhostTrack][AUTOBUILD] %s\n" "$1"
}

log "Inizio rituale di materializzazione GhostTrack‑v3…"

# ============================================================
# 1. DEFINIZIONE MODULI
# ============================================================

MODULES=(
  "cyberdefense"
  "orbital_space"
  "agro_ambiente"
  "resilienza"
  "reti_mesh"
  "ai_analisi"
)

PANEL_DIR="$REPO_ROOT/webapp/static/panels"
STATIC_DIR="$REPO_ROOT/webapp/static"
DOCS_DIR="$REPO_ROOT/docs"

mkdir -p "$PANEL_DIR"
mkdir -p "$DOCS_DIR"

# ============================================================
# 2. INSTALLAZIONE DASHBOARD COMPLETA
# ============================================================

log "Installo dashboard dinamica…"

cat > "$PANEL_DIR/dashboard.html" << 'EOF'
<<< QUI INCOLLO IL FILE DASHBOARD COMPLETO CHE TI HO DATO PRIMA >>>
EOF

# ============================================================
# 3. INSTALLAZIONE PANNELLI DINAMICI
# ============================================================

log "Creo pannelli dinamici per ogni modulo…"

for MOD in "${MODULES[@]}"; do
cat > "$PANEL_DIR/${MOD}.html" << EOF
<div class="gt-panel">

  <header class="gt-panel-header">
    <h1>Modulo: ${MOD}</h1>
    <p class="gt-panel-tagline">
      Stato dinamico e sensori collegati.
    </p>
  </header>

  <section class="gt-section">
    <h2>Dati del modulo</h2>
    <pre class="gt-log-box" id="gt-module-data">
Caricamento…
    </pre>
  </section>

</div>

<script>
document.addEventListener("DOMContentLoaded", async () => {
    const moduleName = "${MOD}";

    const config = await fetch("config.json").then(r => r.json());
    const baseUrl = resolveApiBaseUrl(config);

    await gtLoadSensors();

    const status = await gtCheckModuleStatus(moduleName, baseUrl);

    const box = document.getElementById("gt-module-data");

    if (!status || status.status === "offline") {
        box.textContent = "[" + moduleName + "] Modulo offline.";
    } else {
        box.textContent = JSON.stringify(status.data, null, 2);
    }
});
</script>
EOF
done

# ============================================================
# 4. INSTALLAZIONE ENGINE JAVASCRIPT
# ============================================================

log "Installo engine dinamico app.js…"

cat > "$STATIC_DIR/app.js" << 'EOF'
async function gtLoadSensors() {
    const res = await fetch("sensors.json");
    window.GT_SENSORS = await res.json();
}

async function gtCheckModuleStatus(moduleName, baseUrl) {
    const mod = window.GT_SENSORS.modules[moduleName];
    if (!mod) return null;

    const sensor = mod.sensors[0];
    if (!sensor) return null;

    try {
        const res = await fetch(baseUrl + sensor.endpoint);
        if (!res.ok) return { status: "offline" };
        return { status: "online", data: await res.json() };
    } catch {
        return { status: "offline" };
    }
}
EOF

# ============================================================
# 5. INSTALLAZIONE sensors.json COMPLETO
# ============================================================

log "Installo sensors.json completo…"

cat > "$STATIC_DIR/sensors.json" << 'EOF'
{
  "service": "GhostTrack Sensors Registry",
  "version": "1.0",
  "modules": {
    "cyberdefense": {
      "description": "Superficie di attacco, allarmi, difesa attiva.",
      "protocols": ["http"],
      "sensors": [
        { "id": "cyberdefense_uptime", "type": "http", "endpoint": "/api/cyberdefense/status" }
      ]
    },
    "orbital_space": {
      "description": "Orbite, feed satellitari, spazio vicino.",
      "protocols": ["http", "https"],
      "sensors": [
        { "id": "orbital_space_status", "type": "http", "endpoint": "/api/orbital_space/status" }
      ]
    },
    "agro_ambiente": {
      "description": "Sensori locali, meteo, territorio, suolo.",
      "protocols": ["http", "mqtt"],
      "sensors": [
        { "id": "agro_env_status", "type": "http", "endpoint": "/api/agro_ambiente/status" }
      ]
    },
    "resilienza": {
      "description": "Continuità operativa, allarmi, piani B.",
      "protocols": ["http"],
      "sensors": [
        { "id": "resilience_core", "type": "http", "endpoint": "/api/resilienza/status" }
      ]
    },
    "reti_mesh": {
      "description": "Topologia, link radio, percorsi.",
      "protocols": ["http", "icmp"],
      "sensors": [
        { "id": "network_topology_status", "type": "http", "endpoint": "/api/reti_mesh/status" }
      ]
    },
    "ai_analisi": {
      "description": "Inferenze, correlazioni, scenari.",
      "protocols": ["http"],
      "sensors": [
        { "id": "ai_analysis_status", "type": "http", "endpoint": "/api/ai_analisi/status" }
      ]
    }
  }
}
EOF

# ============================================================
# 6. SYNC STATIC → DOCS
# ============================================================

log "Sincronizzo webapp/static → docs…"

rsync -a --delete "$STATIC_DIR/" "$DOCS_DIR/"

# ============================================================
# 7. GIT ADD / COMMIT / PUSH
# ============================================================

log "Commit e push finale…"

git add webapp/static docs

if git diff --cached --quiet; then
  log "Nessuna modifica da committare."
else
  git commit -m "Autobuild: installazione completa struttura dinamica GhostTrack‑v3"
  git push
fi

log "Materializzazione completa. GhostTrack‑v3 è operativo."
