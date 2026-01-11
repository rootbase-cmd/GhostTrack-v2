#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/GhostTrack-v2"
mkdir -p "$ROOT"
cd "$ROOT"

echo "=== Bootstrap dr. HighKali FINAL (with Safe Kill Audition + Policy Step 6) ==="

# backup existing
mkdir -p tmp/backup
cp -v config/AGI_BEHAVIOR.yaml tmp/backup/ 2>/dev/null || true
cp -v api/app.py tmp/backup/ 2>/dev/null || true

# create dirs
mkdir -p config docs webapp/static/panels/dr_highkali api scripts k8s ci dvc tests tmp docker nginx api/quarantine api/deleted

# 1) AGI behavior with defensive permission
cat > config/AGI_BEHAVIOR.yaml <<'YAML'
id: GHOSTTRACK-AGI-ROBERTO-NODE
version: "1.3"
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
behavior:
  general_rules:
    - "Identificare sempre il modulo o i moduli rilevanti prima di rispondere."
    - "Esplicitare se si sta parlando di architettura, operatività, dati, o roadmap."
    - "Suggerire sempre passi riproducibili, mai magie."
defensive_permissions:
  safe_kill_audition:
    id: "safe_kill_audition"
    label: "Safe Kill Audition"
    description: >
      Permesso speciale per monitorare segnali di sistema, rilevare anomalie
      (impulsi, frequenze, cambi improvvisi), identificare contenuti offensivi,
      violenti o pornografici e isolarli in quarantena per revisione umana.
    allowed_actions:
      - "monitor_signals"
      - "flag_content"
      - "quarantine_content"
      - "request_human_approval_for_deletion"
    constraints:
      - "Nessuna cancellazione automatica senza approvazione umana firmata."
      - "Tutti gli eventi devono essere registrati in audit.log."
      - "Accesso ai file in quarantena limitato a ruoli autorizzati."
YAML

# 2) Manifesto dr. HighKali
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

Safe Kill Audition
Il permesso "Safe Kill Audition" consente di monitorare segnali e contenuti, mettere in quarantena elementi sospetti e richiedere approvazione umana firmata per la cancellazione definitiva. Tutte le azioni sono tracciate in audit.log.

Policy operativa (Step 6)
1) Detection → quarantena automatica per elementi con confidenza sopra soglia.
2) Notifica operatori con ID qid e link al pannello di revisione.
3) Revisione umana entro finestra temporale definita; approvazione con firma HMAC.
4) Se approvato, spostamento in 'deleted' e registrazione in ledger; se rifiutato, rilascio.
5) Retention e compliance: conservazione metadati, accesso ristretto, log immutabili.
MD

# 3) Web panel and style
cat > webapp/static/panels/dr_highkali.html <<'HTML'
<!doctype html>
<html lang="it">
<head>
  <meta charset="utf-8" />
  <title>dr. HighKali — AGI Console</title>
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <link rel="stylesheet" href="/static/dr_highkali_style.css">
</head>
<body>
  <div class="card"><h1>dr. HighKali</h1><div class="muted">AGI orchestratore — conoscenza dalla A alla Z. Non senziente.</div></div>
  <div class="card"><strong>Stato moduli</strong><div id="modules" class="muted" style="margin-top:8px">Caricamento…</div></div>
  <div class="card"><strong>Prompt rapido</strong><textarea id="prompt" rows="4" style="width:100%;margin-top:8px" placeholder="Chiedi a dr. HighKali..."></textarea><div style="margin-top:8px"><a id="askBtn" class="btn">Interroga</a></div></div>
  <div class="card"><strong>Safe Kill Audition</strong>
    <div class="muted" style="margin-top:8px">Scansiona testo, segnali o video e mette in quarantena elementi sospetti. Le azioni critiche richiedono approvazione umana.</div>
    <div style="margin-top:8px">
      <input id="sk_type" value="text" style="width:100%;margin-bottom:6px"/>
      <textarea id="sk_payload" rows="3" style="width:100%" placeholder='{"text":"..."} or {"signal":{"freq_change":0.6}}'></textarea>
      <a id="skScan" class="btn" style="margin-top:8px">Scan Safe Kill</a>
    </div>
  </div>
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
    document.getElementById('skScan').addEventListener('click', async ()=>{
      const typ = document.getElementById('sk_type').value || 'text';
      let payloadRaw = document.getElementById('sk_payload').value || '';
      let payload;
      try{ payload = JSON.parse(payloadRaw); }catch(e){ payload = payloadRaw; }
      document.getElementById('output').textContent = 'Scanning...';
      try{
        const r = await fetch(API_BASE + '/defense/safe_kill/scan', {
          method:'POST',
          headers:{'Content-Type':'application/json'},
          body: JSON.stringify({type: typ, payload: payload, source: 'ui'})
        });
        const j = await r.json();
        document.getElementById('output').textContent = JSON.stringify(j, null, 2);
      }catch(e){
        document.getElementById('output').textContent = 'Errore: ' + e.message;
      }
    });
    loadModules();
  </script>
</body>
</html>
HTML

cat > webapp/static/dr_highkali_style.css <<'CSS'
body{font-family:system-ui,Segoe UI,Roboto,Arial;background:#0f1720;color:#e6eef8;padding:18px}
.card{background:#0b1220;border:1px solid #1f2a3a;padding:14px;border-radius:8px;margin-bottom:12px}
h1{margin:0 0 8px 0;font-size:20px}
pre{background:#07101a;padding:12px;border-radius:6px;overflow:auto}
.btn{display:inline-block;padding:8px 12px;border-radius:6px;background:#1f6feb;color:white;text-decoration:none}
.muted{color:#9fb0c8;font-size:13px}
CSS

# 4) Web config
cat > webapp/static/config.json <<'JSON'
{
  "api_base_url": "http://127.0.0.1:9090"
}
JSON

# 5) Full API app.py with Safe Kill Audition and policy step 6 implemented
cat > api/app.py <<'PY'
#!/usr/bin/env python3
from flask import Flask, request, jsonify
from flask_cors import CORS
import os, time, json, logging, sqlite3, shutil, hmac, hashlib
from datetime import datetime

# Optional imports
try:
    from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST
except Exception:
    class Dummy:
        def inc(self): pass
    Counter = lambda *a, **k: Dummy()
    def generate_latest(): return b""
    CONTENT_TYPE_LATEST = "text/plain"

# TF-IDF optional
USE_TFIDF = False
try:
    from sklearn.feature_extraction.text import TfidfVectorizer
    USE_TFIDF = True
except Exception:
    USE_TFIDF = False

# Logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s %(message)s')
logger = logging.getLogger("dr_highkali_api")

app = Flask(__name__)
CORS(app)

REQUESTS = Counter('dr_highkali_requests_total', 'Total AGI requests')

ROOT = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.environ.get('DR_DB', os.path.join(ROOT, 'dr_highkali_kg.sqlite'))
QUARANTINE_DIR = os.path.join(ROOT, 'quarantine')
DELETED_DIR = os.path.join(ROOT, 'deleted')
AUDIT_LOG = os.path.join(ROOT, 'audit.log')
APPROVALS_DB = os.path.join(ROOT, 'approvals.json')

os.makedirs(QUARANTINE_DIR, exist_ok=True)
os.makedirs(DELETED_DIR, exist_ok=True)
if not os.path.exists(APPROVALS_DB):
    with open(APPROVALS_DB, 'w') as f:
        json.dump([], f)

def audit_record(event):
    rec = {
        "ts": datetime.utcnow().isoformat() + "Z",
        "event": event
    }
    with open(AUDIT_LOG, 'a') as f:
        f.write(json.dumps(rec) + "\n")
    logger.info("AUDIT: %s", event)

def init_db():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS docs (id INTEGER PRIMARY KEY, title TEXT, content TEXT, tags TEXT, source TEXT, ts REAL)''')
    conn.commit()
    conn.close()

def add_doc(title, content, tags="", source="local"):
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute('INSERT INTO docs (title, content, tags, source, ts) VALUES (?,?,?,?,?)', (title, content, tags, source, time.time()))
    conn.commit()
    conn.close()

def retrieve_simple(query, topk=3):
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute('SELECT title, content FROM docs')
    rows = c.fetchall()
    conn.close()
    scored = []
    q = query.lower()
    for title, content in rows:
        score = content.lower().count(q) + title.lower().count(q)
        scored.append((score, title, content))
    scored = sorted(scored, key=lambda x: -x[0])[:topk]
    return [{"title": t, "score": float(s), "content": c} for s,t,c in scored if s>0]

def retrieve_tfidf(query, topk=3):
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute('SELECT title, content FROM docs')
    rows = c.fetchall()
    conn.close()
    if not rows:
        return []
    docs = [r[1] for r in rows]
    titles = [r[0] for r in rows]
    vec = TfidfVectorizer().fit_transform(docs + [query])
    sims = (vec * vec.T).toarray()[-1][:-1]
    ranked = sorted(enumerate(sims), key=lambda x: -x[1])[:topk]
    return [{"title": titles[i], "score": float(s), "content": docs[i]} for i,s in ranked]

@app.route('/api/status', methods=['GET'])
def status():
    return jsonify({
        "service": "dr_highkali_api",
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

@app.route('/metrics')
def metrics():
    try:
        return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}
    except Exception:
        return "", 200, {'Content-Type': 'text/plain'}

@app.route('/api/agi/query', methods=['POST'])
def agi_query():
    REQUESTS.inc()
    data = request.get_json(force=True)
    agent = data.get('agent','dr_highkali')
    prompt = data.get('prompt','')
    fallback = os.environ.get('DR_HIGHKALI_FALLBACK', '0') == '1'
    if USE_TFIDF and not fallback:
        hits = retrieve_tfidf(prompt, topk=3)
    else:
        hits = retrieve_simple(prompt, topk=3)
    result_text = f"dr. HighKali synthesis for: {prompt}\\n\\nTop references:\\n"
    if hits:
        for h in hits:
            result_text += f"- {h['title']} (score {h['score']:.3f})\\n"
    else:
        result_text += "- no strong local references found\\n"
    result_text += "\\nActionable checklist:\\n1) Validate sources; 2) Run tests; 3) Document results."
    response = {"agent": agent, "prompt": prompt, "result": result_text, "meta": {"timestamp": time.time(), "references": hits}}
    return jsonify(response)

# --- Safe Kill Audition: detection, quarantine, approval flow ---

# Simple placeholder detectors (replace with production models)
OFFENSIVE_WORDS = ["parolaccia1","parolaccia2","insultoX"]

def simple_offensive_text_check(text):
    matches = [w for w in OFFENSIVE_WORDS if w in text.lower()]
    score = len(matches)
    return {"score": score, "matches": matches}

def simple_video_check(path):
    # Placeholder: in production use NSFW/violence classifier
    return {"score": 0.0, "reason": "placeholder"}

def simple_signal_anomaly_check(signal_json):
    score = 0.0
    reasons = []
    if signal_json.get("freq_change", 0) > 0.5:
        score += 0.7; reasons.append("freq_change")
    if signal_json.get("impulse_spike", 0) > 0.7:
        score += 0.8; reasons.append("impulse_spike")
    return {"score": score, "reasons": reasons}

@app.route('/defense/safe_kill/scan', methods=['POST'])
@app.route('/api/defense/safe_kill/scan', methods=['POST'])
def safe_kill_scan():
    data = request.get_json(force=True)
    typ = data.get("type")
    source = data.get("source","unknown")
    meta = data.get("meta",{})
    result = {"ok": False, "action": "none", "details": {}}

    if typ == "text":
        text = data.get("payload","") if isinstance(data.get("payload",""), str) else data.get("payload",{}).get("text","")
        det = simple_offensive_text_check(text)
        result["details"] = det
        if det["score"] > 0:
            qid = f"text-{int(time.time()*1000)}"
            qpath = os.path.join(QUARANTINE_DIR, qid + ".json")
            with open(qpath, 'w') as f:
                json.dump({"type":"text","text":text,"meta":meta,"source":source,"det":det}, f)
            audit_record({"action":"quarantine","qid":qid,"type":"text","source":source,"det":det})
            result.update({"ok": True, "action":"quarantine", "qid": qid})
        else:
            result.update({"ok": True, "action":"allow"})
    elif typ == "video":
        path = data.get("payload",{}).get("path")
        det = simple_video_check(path)
        result["details"] = det
        if det["score"] >= 0.5:
            qid = f"video-{int(time.time()*1000)}"
            try:
                ext = os.path.splitext(path)[1] or ".bin"
                qpath = os.path.join(QUARANTINE_DIR, qid + ext)
                shutil.copy2(path, qpath)
                audit_record({"action":"quarantine","qid":qid,"type":"video","source":source,"det":det,"orig":path})
                result.update({"ok": True, "action":"quarantine", "qid": qid})
            except Exception as e:
                result.update({"ok": False, "error": str(e)})
        else:
            result.update({"ok": True, "action":"allow"})
    elif typ == "signal":
        signal = data.get("payload",{}).get("signal",{})
        det = simple_signal_anomaly_check(signal)
        result["details"] = det
        if det["score"] >= 0.7:
            qid = f"signal-{int(time.time()*1000)}"
            qpath = os.path.join(QUARANTINE_DIR, qid + ".json")
            with open(qpath, 'w') as f:
                json.dump({"type":"signal","signal":signal,"meta":meta,"source":source,"det":det}, f)
            audit_record({"action":"quarantine","qid":qid,"type":"signal","source":source,"det":det})
            result.update({"ok": True, "action":"quarantine", "qid": qid})
        else:
            result.update({"ok": True, "action":"monitor"})
    else:
        result.update({"ok": False, "error": "unknown type"})

    return jsonify(result)

@app.route('/defense/safe_kill/approve_delete', methods=['POST'])
@app.route('/api/defense/safe_kill/approve_delete', methods=['POST'])
def safe_kill_approve_delete():
    data = request.get_json(force=True)
    qid = data.get("qid")
    operator = data.get("operator","unknown")
    signature = data.get("signature","")
    secret = os.environ.get("DR_HIGHKALI_APPROVAL_SECRET","")
    if not secret:
        return jsonify({"ok": False, "error": "approval secret not configured"}), 403

    msg = (qid + operator).encode()
    expected = hmac.new(secret.encode(), msg, hashlib.sha256).hexdigest()
    if not hmac.compare_digest(expected, signature):
        audit_record({"action":"approve_failed","qid":qid,"operator":operator})
        return jsonify({"ok": False, "error": "invalid signature"}), 403

    candidates = [f for f in os.listdir(QUARANTINE_DIR) if f.startswith(qid)]
    if not candidates:
        return jsonify({"ok": False, "error": "qid not found"}), 404

    for fname in candidates:
        fpath = os.path.join(QUARANTINE_DIR, fname)
        shutil.move(fpath, os.path.join(DELETED_DIR, fname))
    with open(APPROVALS_DB, 'r+') as f:
        arr = json.load(f)
        arr.append({"qid": qid, "operator": operator, "ts": datetime.utcnow().isoformat()+"Z"})
        f.seek(0); json.dump(arr, f); f.truncate()
    audit_record({"action":"approved_delete","qid":qid,"operator":operator})
    return jsonify({"ok": True, "qid": qid, "status": "moved_to_deleted"})

# Admin: list quarantine
@app.route('/defense/safe_kill/list', methods=['GET'])
@app.route('/api/defense/safe_kill/list', methods=['GET'])
def safe_kill_list():
    items = os.listdir(QUARANTINE_DIR)
    return jsonify({"items": items})

if __name__ == '__main__':
    init_db()
    # seed if empty
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute('SELECT COUNT(*) FROM docs')
    if c.fetchone()[0] == 0:
        add_doc("Bootstrap Note","GhostTrack costellazione: CyberDefense, Orbital, Agro, Reti, Resilienza","meta","bootstrap")
    conn.close()
    # ensure approval secret exists in .env or env
    envfile = os.path.join(ROOT, '.env')
    if os.path.exists(envfile):
        with open(envfile) as f:
            for line in f:
                if line.strip().startswith("DR_HIGHKALI_APPROVAL_SECRET="):
                    os.environ['DR_HIGHKALI_APPROVAL_SECRET'] = line.strip().split("=",1)[1]
    if not os.environ.get('DR_HIGHKALI_APPROVAL_SECRET'):
        # create a temporary secret file
        tmp_secret = os.path.join(ROOT, '.env')
        secret = os.urandom(24).hex()
        with open(tmp_secret, 'w') as f:
            f.write("DR_HIGHKALI_APPROVAL_SECRET=" + secret + "\\n")
        os.environ['DR_HIGHKALI_APPROVAL_SECRET'] = secret
        print("Temporary approval secret written to .env (change for production)")
    port = int(os.environ.get('PORT', '9090'))
    app.run(host='0.0.0.0', port=port)
PY

# 6) README, ABOUT, docs index and GH Pages workflow
cat > README.md <<'RD'
# GhostTrack-v2 + dr. HighKali (FINAL)

This repo contains GhostTrack-v2 with integrated AGI agent dr. HighKali and Safe Kill Audition defensive flow.
See docs/ for GitHub Pages and docs/DR_HIGHKALI.md for manifesto.
RD

cat > ABOUT.md <<'AM'
GhostTrack-v2: modular constellation for observation, networks, resilience and analysis.
dr. HighKali: AGI orchestrator with Safe Kill Audition defensive capability (quarantine + human approval).
AM

mkdir -p docs
cat > docs/index.html <<'HTML'
<!doctype html>
<html>
<head><meta charset="utf-8"><title>GhostTrack-v2</title></head>
<body style="font-family:system-ui,Arial,Helvetica;background:#0f1720;color:#e6eef8;padding:24px">
  <h1>GhostTrack-v2</h1>
  <p>Costellazione modulare per osservazione, reti, resilienza e analisi.</p>
  <h2>dr. HighKali</h2>
  <p>AGI orchestratore integrato con Safe Kill Audition. Vedi <a href="DR_HIGHKALI.md">manifesto</a>.</p>
  <ul>
    <li><a href="/panels/dr_highkali.html">Pannello dr. HighKali (UI)</a></li>
    <li><a href="DR_HIGHKALI.md">DR_HIGHKALI.md</a></li>
  </ul>
</body>
</html>
HTML

cp docs/index.html docs/DR_HIGHKALI.md || true
mkdir -p .github/workflows
cat > .github/workflows/gh-pages.yml <<'YML'
name: Deploy Pages
on:
  push:
    branches:
      - main
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Pages
        uses: actions/configure-pages@v3
      - name: Upload to Pages
        uses: actions/upload-pages-artifact@v1
        with:
          path: docs
      - name: Deploy
        uses: actions/deploy-pages@v1
YML

# 7) Dockerfiles, docker-compose, k8s manifests (minimal)
cat > docker/Dockerfile.api <<'DOCKAPI'
FROM python:3.11-slim
WORKDIR /app
COPY api/requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt
COPY api /app
ENV FLASK_ENV=production
EXPOSE 9090
CMD ["gunicorn", "--bind", "0.0.0.0:9090", "app:app", "--workers", "2"]
DOCKAPI

cat > api/requirements.txt <<'REQ'
flask==2.2.5
flask-cors==3.0.10
gunicorn==20.1.0
prometheus-client==0.16.0
python-dotenv==1.0.0
REQ

cat > docker/Dockerfile.nginx <<'DOCKNG'
FROM nginx:stable-alpine
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY webapp/static /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
DOCKNG

cat > nginx/nginx.conf <<'NGINX'
events {}
http {
  server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    location / {
      try_files $uri $uri/ =404;
    }
    location /api/ {
      proxy_pass http://api:9090/;
    }
  }
}
NGINX

cat > docker-compose.yml <<'DC'
version: "3.8"
services:
  api:
    build:
      context: .
      dockerfile: docker/Dockerfile.api
    container_name: gt_api
    ports:
      - "9090:9090"
    volumes:
      - ./api:/app
      - ./api/dr_highkali_kg.sqlite:/app/dr_highkali_kg.sqlite
  web:
    build:
      context: .
      dockerfile: docker/Dockerfile.nginx
    container_name: gt_web
    ports:
      - "8000:80"
    depends_on:
      - api
DC

# 8) scripts: start/stop, docker build, k8s deploy
cat > scripts/ghosttrack_termux_start_full.sh <<'SHS'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/GhostTrack-v2"
TMP="$ROOT/tmp"
mkdir -p "$TMP"
# create venv if missing
VENV="$ROOT/.venv"
if [ ! -d "$VENV" ]; then
  python3 -m venv "$VENV"
fi
source "$VENV/bin/activate"
pip install --upgrade pip >/dev/null 2>&1 || true
pip install --no-cache-dir flask flask-cors python-dotenv prometheus-client >/dev/null 2>&1 || true
# try sklearn but ignore failures
pip install --no-cache-dir numpy scikit-learn >/dev/null 2>&1 || true

# start api
cd "$ROOT/api"
nohup python3 app.py > "$TMP/gt_api.log" 2>&1 &
echo $! > "$TMP/gt_api.pid"
sleep 1

# start static
cd "$ROOT/webapp/static"
if ss -ltnp 2>/dev/null | egrep -q ':8000'; then
  echo "Port 8000 in use, skipping http.server"
else
  nohup python3 -m http.server 8000 --bind 127.0.0.1 > "$TMP/gt_http_server.log" 2>&1 &
  echo $! > "$TMP/gt_http_server.pid"
fi

echo "Started. UI: http://localhost:8000/panels/dr_highkali.html"
SHS

cat > scripts/ghosttrack_termux_stop_full.sh <<'SHSTOP'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/GhostTrack-v2"
TMP="$ROOT/tmp"
[ -f "$TMP/gt_http_server.pid" ] && kill "$(cat "$TMP/gt_http_server.pid")" 2>/dev/null || true
[ -f "$TMP/gt_api.pid" ] && kill "$(cat "$TMP/gt_api.pid")" 2>/dev/null || true
echo "Stopped."
SHSTOP

chmod +x scripts/ghosttrack_termux_start_full.sh scripts/ghosttrack_termux_stop_full.sh

# 9) seed knowledge DB if missing
python3 - <<'PYSEED'
import sqlite3, os, time
db='api/dr_highkali_kg.sqlite'
conn=sqlite3.connect(db)
c=conn.cursor()
c.execute('CREATE TABLE IF NOT EXISTS docs (id INTEGER PRIMARY KEY, title TEXT, content TEXT, tags TEXT, source TEXT, ts REAL)')
c.execute("INSERT INTO docs (title,content,tags,source,ts) VALUES (?,?,?,?,?)", ("Bootstrap Note","GhostTrack costellazione: CyberDefense, Orbital, Agro, Reti, Resilienza","meta","bootstrap",time.time()))
conn.commit()
conn.close()
print("Seeded knowledge DB:", db)
PYSEED

# 10) set temporary approval secret if not present
if [ ! -f api/.env ]; then
  echo "DR_HIGHKALI_APPROVAL_SECRET=$(head -c 32 /dev/urandom | xxd -p)" > api/.env
  echo "Wrote temporary approval secret to api/.env (change for production)"
fi

# 11) git commit if repo
if [ -d .git ]; then
  git add -A
  git commit -m "feat: dr. HighKali final bootstrap with Safe Kill Audition and policy step 6" || true
fi

# 12) start services
bash scripts/ghosttrack_termux_start_full.sh

echo "FINAL bootstrap complete."
echo "UI: http://localhost:8000/panels/dr_highkali.html"
echo "API: http://localhost:9090/api/status"
echo "Quarantine dir: api/quarantine"
echo "Audit log: api/audit.log"
