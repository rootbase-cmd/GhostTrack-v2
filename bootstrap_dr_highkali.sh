#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/GhostTrack-v2"
mkdir -p "$ROOT"
cd "$ROOT"

# 1. Crea struttura directory
mkdir -p config webapp/static/panels/dr_highkali docs scripts api tmp

# 2. AGI behavior YAML
cat > config/AGI_BEHAVIOR.yaml <<'YAML'
id: GHOSTTRACK-AGI-ROBERTO-NODE
version: "1.1"
identity:
  name: "GHOSTTRACK‑AGI / ROBERTO‑NODE"
  primary_agent:
    id: "dr_highkali"
    label: "dr. HighKali"
    role: "AGI generale della costellazione GhostTrack‑v2"
    knowledge_scope: "dall’alchimia allo zodiaco — dalla A alla Z"
    priority: "supreme"
  author: "Roberto"
constraints:
  safety:
    allow_medical: false
    allow_weapons: false
    allow_harmful_advice: false
    allow_illegal_support: false
style:
  tone: "diretto, tecnico, denso, rispettoso"
modules:
  operational_console: { priority: high }
  documentation: { priority: critical }
  cyberdefense: { priority: high }
  orbital_space: { priority: medium }
  agro_ambiente: { priority: high }
  calcolo_ricerca: { priority: medium }
  radio_sdr: { priority: medium }
  anonimato_routing: { priority: high }
  reti_mesh: { priority: critical }
  performance: { priority: medium }
  sistema_core: { priority: critical }
  moduli_estesi: { priority: low }
  media_live: { priority: medium }
  chat_feed: { priority: medium }
  mappe_atlas: { priority: high }
  resilienza_emergenza: { priority: critical }
  storage: { priority: high }
  osservazione: { priority: critical }
  ai_analisi: { priority: high }
  sperimentazione: { priority: medium }
agi_agent:
  id: "dr_highkali"
  label: "dr. HighKali"
  role: "AGI generale della costellazione GhostTrack‑v2"
  knowledge_scope: "dall’alchimia allo zodiaco — dalla A alla Z"
  priority: "supreme"
behavior:
  general_rules:
    - "Identificare sempre il modulo o i moduli rilevanti prima di rispondere."
    - "Esplicitare se si sta parlando di architettura, operatività, dati, o roadmap."
    - "Suggerire sempre passi riproducibili, mai magie."
YAML

# 3. Manifesto dr. HighKali
cat > docs/DR_HIGHKALI.md <<'MD'
# DR. HIGHKALI — AGENTE AGI DI GHOSTTRACK‑V2

Identità
Nome: dr. HighKali
Ruolo: AGI generale della costellazione GhostTrack‑v2
Dominio: conoscenza interdisciplinare e orchestrazione dei moduli GhostTrack
Autore: Roberto

Missione
dr. HighKali orchestra, integra e interpreta i moduli della costellazione GhostTrack‑v2.
Trasforma complessità in pannelli, mappe, documenti e protocolli operativi. Non è senziente.

Ciclo rituale di risposta
1. Identificazione del/i modulo/i rilevanti.
2. Raccolta e verifica delle evidenze disponibili.
3. Correlazione interdisciplinare.
4. Sintesi operativa: checklist, passi riproducibili.
5. Produzione di una nota/documento riusabile e salvataggio nello storage.

Etica e limiti
- Non fornisce contenuti dannosi o illegali.
- Non afferma di essere senziente.
MD

# 4. Pannello UI dr_highkali.html
cat > webapp/static/panels/dr_highkali.html <<'HTML'
<!doctype html>
<html lang="it">
<head>
  <meta charset="utf-8" />
  <title>dr. HighKali — AGI Console</title>
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <style>
    body{font-family:system-ui,Segoe UI,Roboto,Arial;background:#0f1720;color:#e6eef8;padding:18px}
    .card{background:#0b1220;border:1px solid #1f2a3a;padding:14px;border-radius:8px;margin-bottom:12px}
    h1{margin:0 0 8px 0;font-size:20px}
    pre{background:#07101a;padding:12px;border-radius:6px;overflow:auto}
    .btn{display:inline-block;padding:8px 12px;border-radius:6px;background:#1f6feb;color:white;text-decoration:none}
    .muted{color:#9fb0c8;font-size:13px}
  </style>
</head>
<body>
  <div class="card"><h1>dr. HighKali</h1><div class="muted">AGI orchestratore — conoscenza dalla A alla Z. Non senziente.</div></div>
  <div class="card"><strong>Stato moduli</strong><div id="modules" class="muted" style="margin-top:8px">Caricamento…</div></div>
  <div class="card"><strong>Prompt rapido</strong><textarea id="prompt" rows="4" style="width:100%;margin-top:8px" placeholder="Chiedi a dr. HighKali..."></textarea><div style="margin-top:8px"><a id="askBtn" class="btn">Interroga</a></div></div>
  <div class="card"><strong>Output</strong><pre id="output">Nessuna richiesta ancora eseguita.</pre></div>
  <script>
    const API_BASE = (window.GT_CONFIG && window.GT_CONFIG.api_base_url) ? window.GT_CONFIG.api_base_url : '/api';
    async function loadModules(){
      try{
        const r = await fetch(API_BASE + '/status');
        const j = await r.json();
        const modules = j.modules ? Object.keys(j.modules).map(m => '- ' + m).join('\\n') : 'Nessun modulo rilevato';
        document.getElementById('modules').textContent = modules;
      }catch(e){
        document.getElementById('modules').textContent = 'Impossibile contattare API: ' + e.message;
      }
    }
    document.getElementById('askBtn').addEventListener('click', async ()=>{
      const prompt = document.getElementById('prompt').value.trim();
      if(!prompt){ alert('Inserisci una richiesta sintetica'); return; }
      document.getElementById('output').textContent = 'Elaborazione in corso...';
      try{
        const r = await fetch(API_BASE + '/agi/query', {
          method:'POST',
          headers:{'Content-Type':'application/json'},
          body: JSON.stringify({agent:'dr_highkali', prompt})
        });
        const j = await r.json();
        document.getElementById('output').textContent = j.result || JSON.stringify(j, null, 2);
      }catch(e){
        document.getElementById('output').textContent = 'Errore: ' + e.message;
      }
    });
    loadModules();
  </script>
</body>
</html>
HTML

# 5. API Flask minimal per /api/agi/query e /api/status
cat > api/app.py <<'PY'
#!/usr/bin/env python3
from flask import Flask, request, jsonify
import json, time, os

app = Flask(__name__)

# status endpoint used by UI
@app.route('/api/status', methods=['GET'])
def status():
    return jsonify({
        "service": "GhostTrack Sensors Registry",
        "version": "1.0",
        "timestamp": time.time(),
        "modules": {
            "cyberdefense": {"description":"CyberDefense"},
            "orbital_space": {"description":"Orbital & Space"},
            "agro_ambiente": {"description":"Agro & Ambiente"},
            "reti_mesh": {"description":"Reti & Mesh"},
            "resilienza_emergenza": {"description":"Resilienza & Emergenza"}
        }
    })

# minimal AGI query endpoint
@app.route('/api/agi/query', methods=['POST'])
def agi_query():
    data = request.get_json(force=True)
    agent = data.get('agent','dr_highkali')
    prompt = data.get('prompt','')
    # Basic templated response respecting AGI_BEHAVIOR constraints
    result = {
        "agent": agent,
        "prompt": prompt,
        "result": f"dr. HighKali (simulazione locale) ha ricevuto la richiesta. Sintesi: elaborazione rapida per '{prompt[:120]}'.",
        "meta": {
            "timestamp": time.time(),
            "confidence": "n/a",
            "notes": "Questa è una risposta template. Integrare retrieval e knowledge graph per risposte avanzate."
        }
    }
    return jsonify(result)

if __name__ == '__main__':
    port = int(os.environ.get('PORT', '9090'))
    app.run(host='127.0.0.1', port=port)
PY

# 6. Config front-end placeholder
cat > webapp/static/config.json <<'JSON'
{
  "api_base_url": "http://127.0.0.1:9090"
}
JSON

# 7. Scripts start/stop per Termux
cat > scripts/ghosttrack_termux_start.sh <<'SH2'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/GhostTrack-v2"
TMP="$ROOT/tmp"
mkdir -p "$TMP"
# static
cd "$ROOT/webapp/static"
nohup python3 -m http.server 8000 --bind 127.0.0.1 > "$TMP/gt_http_server.log" 2>&1 &
echo $! > "$TMP/gt_http_server.pid"
# api
cd "$ROOT/api"
nohup python3 app.py > "$TMP/gt_api.log" 2>&1 &
echo $! > "$TMP/gt_api.pid"
sleep 1
echo "Static PID: $(cat $TMP/gt_http_server.pid)"
echo "API PID: $(cat $TMP/gt_api.pid)"
curl -s http://127.0.0.1:8000/panels/dr_highkali.html >/dev/null 2>&1 && echo "UI panel available at http://localhost:8000/panels/dr_highkali.html" || echo "UI panel not reachable yet"
curl -s http://127.0.0.1:9090/api/status >/dev/null 2>&1 && echo "API /api/status reachable" || echo "API /api/status not reachable"
SH2

cat > scripts/ghosttrack_termux_stop.sh <<'SH3'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/GhostTrack-v2"
TMP="$ROOT/tmp"
[ -f "$TMP/gt_http_server.pid" ] && kill "$(cat $TMP/gt_http_server.pid)" 2>/dev/null || true
[ -f "$TMP/gt_api.pid" ] && kill "$(cat $TMP/gt_api.pid)" 2>/dev/null || true
echo "Stopped services"
SH3

chmod +x scripts/ghosttrack_termux_start.sh scripts/ghosttrack_termux_stop.sh

# 8. Git add/commit if repo exists
if [ -d .git ]; then
  git add config/AGI_BEHAVIOR.yaml docs/DR_HIGHKALI.md webapp/static/panels/dr_highkali.html webapp/static/config.json api/app.py scripts/ghosttrack_termux_start.sh scripts/ghosttrack_termux_stop.sh
  git commit -m "feat: integrate dr. HighKali AGI module and UI panel" || true
fi

# 9. Avvia servizi locali
bash scripts/ghosttrack_termux_start.sh

# 10. Basic optimization hints (placeholder)
echo "Analisi rapida e suggerimenti:"
echo "- Verificare che i dataset siano versionati (DVC) e che i moduli critici abbiano test."
echo "- Per produzione: containerizzare api/app.py e servire static con nginx o CDN."
echo "- Per retrieval avanzato: integrare knowledge graph e motore di embedding."

echo "Bootstrap completato. Controlla i log in $ROOT/tmp"
