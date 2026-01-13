#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${REPO_ROOT}"

log() {
  printf "\n[GhostTrack][FINALIZE] %s\n" "$1"
}

# Costellazione moduli ufficiale
MODULES=(
  "cyberdefense"
  "orbital_space"
  "agro_ambiente"
  "resilienza"
  "reti_mesh"
  "ai_analisi"
)

PANEL_DIR="${REPO_ROOT}/webapp/static/panels"
DOCS_DIR="${REPO_ROOT}/docs"

# 0. Controllo repo git
if [ ! -d ".git" ]; then
  log "Questa directory non è un repository Git. Interrompo."
  exit 1
fi

log "Materializzazione finale della costellazione GhostTrack-v3…"

# 1. Garantire pannelli per ogni modulo
log "Verifico e creo i pannelli HTML per ogni modulo…"
mkdir -p "${PANEL_DIR}"

for MOD in "${MODULES[@]}"; do
  PANEL_FILE="${PANEL_DIR}/${MOD}.html"
  if [ ! -f "${PANEL_FILE}" ]; then
    log "Creo pannello base per modulo: ${MOD}"
    cat > "${PANEL_FILE}" << EOP
<div class="gt-panel">
  <header class="gt-panel-header">
    <h1>$(echo "${MOD}" | sed 's/_/ \&amp; /g' | sed 's/\b\(.\)/\u\1/g')</h1>
    <p class="gt-panel-tagline">
      Pannello base per il dominio operativo <strong>${MOD}</strong>.
    </p>
  </header>

  <section class="gt-section">
    <h2>Descrizione</h2>
    <p>
      Questo pannello rappresenta il dominio <strong>${MOD}</strong> della costellazione GhostTrack.
      È un placeholder pronto per essere collegato a sensori, protocolli e fonti dati reali.
    </p>
  </section>

  <section class="gt-section">
    <h2>API e sensori previsti</h2>
    <ul>
      <li>Endpoint di stato: <code>/api/${MOD}/status</code></li>
      <li>Sensori definiti in: <code>webapp/static/sensors.json</code></li>
      <li>Documentazione dominio: <code>docs/MODULE_$(echo "${MOD}" | tr '[:lower:]' '[:upper:]').md</code></li>
    </ul>
  </section>
</div>
EOP
  else
    log "Pannello già presente per modulo: ${MOD}"
  fi
done

# 2. Documenti base per ogni modulo
log "Creo (se mancanti) i documenti base per i domini in docs/…"
mkdir -p "${DOCS_DIR}" "${DOCS_DIR}/panels"

for MOD in "${MODULES[@]}"; do
  UPPER_NAME=$(echo "${MOD}" | tr '[:lower:]' '[:upper:]')
  DOC_FILE="${DOCS_DIR}/MODULE_${UPPER_NAME}.md"
  if [ ! -f "${DOC_FILE}" ]; then
    log "Creo documento base: MODULE_${UPPER_NAME}.md"
    cat > "${DOC_FILE}" << EOD
# Dominio: ${MOD}

Questo documento descrive il dominio operativo **${MOD}** della costellazione GhostTrack.

## Scopo

- Definire l'ambito del dominio.
- Elencare sensori, feed e protocolli rilevanti.
- Tracciare lo stato di materializzazione del modulo.

## Sensori e fonti previsti

- Vedi \`webapp/static/sensors.json\` per l'elenco completo dei sensori associati.

## Endpoint API previsti

- \`/api/${MOD}/status\` – Stato sintetico del dominio.
- Endpoint futuri da aggiungere in \`api/app.py\`.

EOD
  else
    log "Documento già presente per dominio: MODULE_${UPPER_NAME}.md"
  fi
done

# 3. Registro globale sensori e protocolli
log "Genero registro sensori e protocolli in webapp/static/sensors.json…"

SENSORS_FILE="${REPO_ROOT}/webapp/static/sensors.json"
mkdir -p "${REPO_ROOT}/webapp/static"

cat > "${SENSORS_FILE}" << EOS
{
  "service": "GhostTrack Sensors Registry",
  "version": "1.0",
  "description": "Registro centrale di moduli, sensori e protocolli della costellazione GhostTrack-v3.",
  "modules": {
    "cyberdefense": {
      "description": "Superficie di attacco, allarmi, difesa attiva.",
      "protocols": ["http", "https"],
      "sensors": [
        {
          "id": "cyberdefense_uptime",
          "type": "http",
          "endpoint": "/api/cyberdefense/status",
          "description": "Stato sintetico del modulo CyberDefense."
        }
      ]
    },
    "orbital_space": {
      "description": "Orbite, feed satellitari, spazio vicino.",
      "protocols": ["http", "https"],
      "sensors": [
        {
          "id": "orbital_space_status",
          "type": "http",
          "endpoint": "/api/orbital_space/status",
          "description": "Stato sintetico del modulo Orbital & Space."
        }
      ]
    },
    "agro_ambiente": {
      "description": "Sensori locali, meteo, territorio, suolo.",
      "protocols": ["http", "mqtt"],
      "sensors": [
        {
          "id": "agro_env_status",
          "type": "http",
          "endpoint": "/api/agro_ambiente/status",
          "description": "Stato sintetico del modulo Agro & Ambiente."
        }
      ]
    },
    "resilienza": {
      "description": "Continuità operativa, allarmi, piani B.",
      "protocols": ["http"],
      "sensors": [
        {
          "id": "resilience_core",
          "type": "http",
          "endpoint": "/api/resilienza/status",
          "description": "Stato di resilienza del nodo GhostTrack."
        }
      ]
    },
    "reti_mesh": {
      "description": "Topologia, link radio, percorsi.",
      "protocols": ["http", "icmp"],
      "sensors": [
        {
          "id": "network_topology_status",
          "type": "http",
          "endpoint": "/api/reti_mesh/status",
          "description": "Stato sintetico del dominio reti e mesh."
        }
      ]
    },
    "ai_analisi": {
      "description": "Inferenze, correlazioni, scenari.",
      "protocols": ["http"],
      "sensors": [
        {
          "id": "ai_analysis_status",
          "type": "http",
          "endpoint": "/api/ai_analisi/status",
          "description": "Stato sintetico del modulo AI & Analisi."
        }
      ]
    }
  }
}
EOS

log "Registro sensori aggiornato: ${SENSORS_FILE}"

# 4. Sync webapp/static -> docs
log "Sincronizzo webapp/static/ → docs/ …"
mkdir -p "${DOCS_DIR}"

if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete "${REPO_ROOT}/webapp/static/" "${DOCS_DIR}/"
else
  log "rsync non trovato, uso cp come fallback…"
  rm -rf "${DOCS_DIR:?}/"*
  cp -r "${REPO_ROOT}/webapp/static/"* "${DOCS_DIR}/" 2>/dev/null || true
fi

# 5. Git status, add, commit, push
log "Stato del repository dopo la materializzazione:"
git status --short

log "Eseguo git add per UI, docs e registro sensori…"
git add webapp/static docs

if git diff --cached --quiet; then
  log "Nessuna modifica da committare. Il sistema è già allineato."
  exit 0
fi

COMMIT_MSG="${1:-Finalize GhostTrack-v3 constellation and sensors registry}"
log "Creo commit: ${COMMIT_MSG}"
git commit -m "${COMMIT_MSG}"

log "Eseguo git push…"
git push

log "Materializzazione finale completata. La costellazione GhostTrack-v3 è dichiarata."
