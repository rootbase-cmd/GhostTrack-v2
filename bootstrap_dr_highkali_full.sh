#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/GhostTrack-v2"
mkdir -p "$ROOT"
cd "$ROOT"

echo "Bootstrap dr. HighKali full integration starting..."

# Create directories
mkdir -p config docs webapp/static/panels/dr_highkali api scripts k8s ci dvc tests tmp docker nginx

# 1) AGI behavior and manifesto
cat > config/AGI_BEHAVIOR.yaml <<'YAML'
id: GHOSTTRACK-AGI-ROBERTO-NODE
version: "1.2"
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
agi_agent:
  id: "dr_highkali"
  label: "dr. HighKali"
  knowledge_scope: "dall’alchimia allo zodiaco — dalla A alla Z"
  priority: "supreme"
YAML

cat > docs/DR_HIGHKALI.md <<'MD'
# DR. HIGHKALI — AGENTE AGI DI GHOSTTRACK‑V2

Identità, missione, limiti e rituali operativi.
Vedi config/AGI_BEHAVIOR.yaml per la versione macchina.
MD

# 2) Frontend panel (keeps previous style)
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

cat > webapp/static/dr_highkali_style.css <<'CSS'
body{font-family:system-ui,Segoe UI,Roboto,Arial;background:#0f1720;color:#e6eef8;padding:18px}
.card{background:#0b1220;border:1px solid #1f2a3a;padding:14px;border-radius:8px;margin-bottom:12px}
h1{margin:0 0 8px 0;font-size:20px}
pre{background:#07101a;padding:12px;border-radius:6px;overflow:auto}
.btn{display:inline-block;padding:8px 12px;border-radius:6px;background:#1f6feb;color:white;text-decoration:none}
.muted{color:#9fb0c8;font-size:13px}
CSS

# 3) Web config
cat > webapp/static/config.json <<'JSON'
{
  "api_base_url": "http://127.0.0.1:9090"
}
JSON

# 4) API with retrieval placeholder, metrics, logging, and AGI wrapper
cat > api/requirements.txt <<'REQ'
flask==2.2.5
flask-cors==3.0.10
gunicorn==20.1.0
scikit-learn==1.3.2
numpy==1.26.4
prometheus-client==0.16.0
python-dotenv==1.0.0
REQ

cat > api/app.py <<'PY'
#!/usr/bin/env python3
from flask import Flask, request, jsonify
from flask_cors import CORS
import os, time, json, logging
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST
from sklearn.feature_extraction.text import TfidfVectorizer
import sqlite3

# Basic logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s %(message)s')
logger = logging.getLogger("dr_highkali_api")

app = Flask(__name__)
CORS(app)

# Prometheus metrics
REQUESTS = Counter('dr_highkali_requests_total', 'Total AGI requests')

# Simple local knowledge store using sqlite and TF-IDF retrieval as placeholder
DB_PATH = os.environ.get('DR_DB', 'dr_highkali_kg.sqlite')

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

def retrieve(query, topk=3):
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute('SELECT id, title, content FROM docs')
    rows = c.fetchall()
    conn.close()
    if not rows:
        return []
    docs = [r[2] for r in rows]
    titles = [r[1] for r in rows]
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
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

@app.route('/api/agi/query', methods=['POST'])
def agi_query():
    REQUESTS.inc()
    data = request.get_json(force=True)
    agent = data.get('agent','dr_highkali')
    prompt = data.get('prompt','')
    # Safety check from config
    # Retrieval
    hits = retrieve(prompt, topk=3)
    # Template reasoning pipeline
    result_text = f"dr. HighKali synthesis for: {prompt}\\n\\nTop references:\\n"
    for h in hits:
        result_text += f"- {h['title']} (score {h['score']:.3f})\\n"
    result_text += "\\nActionable checklist:\\n1) Validate sources; 2) Run tests; 3) Document results."
    response = {
        "agent": agent,
        "prompt": prompt,
        "result": result_text,
        "meta": {"timestamp": time.time(), "references": hits}
    }
    return jsonify(response)

# Admin endpoints to seed knowledge
@app.route('/api/agi/seed', methods=['POST'])
def seed():
    data = request.get_json(force=True)
    docs = data.get('docs', [])
    for d in docs:
        add_doc(d.get('title','untitled'), d.get('content',''), d.get('tags',''), d.get('source','manual'))
    return jsonify({"status":"ok","added":len(docs)})

if __name__ == '__main__':
    init_db()
    # seed a few docs if empty
    if os.path.exists(DB_PATH):
        pass
    else:
        add_doc("Intro GhostTrack", "GhostTrack costellazione: CyberDefense, Orbital, Agro, Reti, Resilienza", "meta", "bootstrap")
    port = int(os.environ.get('PORT', '9090'))
    app.run(host='0.0.0.0', port=port)
PY

# 5) Dockerfile for API and nginx for static
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

# 6) docker-compose for local containerized run
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

# 7) Kubernetes manifests (deployment, service, ingress, rbac)
cat > k8s/deployment-api.yaml <<'KDEP'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dr-highkali-api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: dr-highkali-api
  template:
    metadata:
      labels:
        app: dr-highkali-api
    spec:
      containers:
        - name: api
          image: ghcr.io/yourorg/dr-highkali-api:latest
          ports:
            - containerPort: 9090
          env:
            - name: PORT
              value: "9090"
KDEP

cat > k8s/service-api.yaml <<'KSVC'
apiVersion: v1
kind: Service
metadata:
  name: dr-highkali-api
spec:
  selector:
    app: dr-highkali-api
  ports:
    - protocol: TCP
      port: 9090
      targetPort: 9090
  type: ClusterIP
KSVC

cat > k8s/deployment-web.yaml <<'KWEB'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dr-highkali-web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: dr-highkali-web
  template:
    metadata:
      labels:
        app: dr-highkali-web
    spec:
      containers:
        - name: web
          image: ghcr.io/yourorg/dr-highkali-web:latest
          ports:
            - containerPort: 80
KWEB

cat > k8s/service-web.yaml <<'KWEBS'
apiVersion: v1
kind: Service
metadata:
  name: dr-highkali-web
spec:
  selector:
    app: dr-highkali-web
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer
KWEBS

cat > k8s/ingress.yaml <<'KING'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: dr-highkali-ingress
spec:
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: dr-highkali-web
                port:
                  number: 80
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: dr-highkali-api
                port:
                  number: 9090
KING

# 8) RBAC placeholder and OIDC notes
cat > k8s/rbac.yaml <<'RBAC'
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dr-highkali-sa
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: dr-highkali-role
rules:
  - apiGroups: [""]
    resources: ["pods","services","endpoints"]
    verbs: ["get","list","watch"]
RBAC

cat > k8s/README_RBAC_OIDC.md <<'TXT'
RBAC and OIDC integration:
- Replace placeholders with your OIDC provider (Keycloak, Auth0, Azure AD).
- Configure Ingress with TLS and OIDC auth.
- Use Kubernetes secrets for client IDs and secrets.
TXT

# 9) DVC placeholder and data policy
mkdir -p dvc
cat > dvc/config <<'DVC'
[core]
    remote = storage
DVC

cat > dvc/README_DVC.md <<'DVCMD'
DVC setup:
- Install dvc and configure remote storage (S3, GCS, or SSH).
- Track large datasets and models with dvc add and dvc push.
DVCMD

# 10) CI GitHub Actions workflow for build/test
mkdir -p .github/workflows
cat > .github/workflows/ci.yml <<'YAML'
name: CI
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      - name: Install dependencies
        run: |
          pip install -r api/requirements.txt
      - name: Run tests
        run: |
          pytest -q
      - name: Build Docker images
        run: |
          docker build -f docker/Dockerfile.api -t dr-highkali-api:ci .
          docker build -f docker/Dockerfile.nginx -t dr-highkali-web:ci .
YAML

# 11) Tests (pytest) basic
cat > tests/test_api_basic.py <<'PYT'
import requests
def test_status():
    r = requests.get("http://127.0.0.1:9090/api/status")
    assert r.status_code == 200
PYT

# 12) Simple pytest config
cat > pytest.ini <<'PYI'
[pytest]
addopts = -q
PYI

# 13) Scripts for Termux start/stop, docker build, k8s deploy
cat > scripts/ghosttrack_termux_start_full.sh <<'SHS'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/GhostTrack-v2"
TMP="$ROOT/tmp"
mkdir -p "$TMP"
# If docker available, use docker-compose
if command -v docker >/dev/null 2>&1 && command -v docker-compose >/dev/null 2>&1; then
  echo "Docker detected: building and starting containers..."
  docker-compose build
  docker-compose up -d
  echo "Containers started: web on http://localhost:8000, api on http://localhost:9090"
else
  echo "Docker not found: starting services directly"
  cd "$ROOT/webapp/static"
  nohup python3 -m http.server 8000 --bind 127.0.0.1 > "$TMP/gt_http_server.log" 2>&1 &
  echo $! > "$TMP/gt_http_server.pid"
  cd "$ROOT/api"
  nohup python3 app.py > "$TMP/gt_api.log" 2>&1 &
  echo $! > "$TMP/gt_api.pid"
  echo "Local servers started"
fi
SHS

cat > scripts/ghosttrack_termux_stop_full.sh <<'SHSTOP'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/GhostTrack-v2"
TMP="$ROOT/tmp"
if command -v docker >/dev/null 2>&1 && command -v docker-compose >/dev/null 2>&1; then
  docker-compose down
else
  [ -f "$TMP/gt_http_server.pid" ] && kill "$(cat $TMP/gt_http_server.pid)" 2>/dev/null || true
  [ -f "$TMP/gt_api.pid" ] && kill "$(cat $TMP/gt_api.pid)" 2>/dev/null || true
fi
echo "Stopped."
SHSTOP

chmod +x scripts/ghosttrack_termux_start_full.sh scripts/ghosttrack_termux_stop_full.sh

# 14) Kubernetes deploy helper (minikube)
cat > scripts/k8s_deploy.sh <<'KDEP'
#!/usr/bin/env bash
set -euo pipefail
echo "Applying k8s manifests..."
kubectl apply -f k8s/rbac.yaml
kubectl apply -f k8s/deployment-api.yaml
kubectl apply -f k8s/service-api.yaml
kubectl apply -f k8s/deployment-web.yaml
kubectl apply -f k8s/service-web.yaml
kubectl apply -f k8s/ingress.yaml
echo "Manifests applied. Configure ingress controller and TLS separately."
KDEP
chmod +x scripts/k8s_deploy.sh

# 15) Docker build script
cat > scripts/docker_build_push.sh <<'DBP'
#!/usr/bin/env bash
set -euo pipefail
# Replace registry and tags as needed
REGISTRY=${1:-ghcr.io/yourorg}
TAG=${2:-latest}
docker build -f docker/Dockerfile.api -t $REGISTRY/dr-highkali-api:$TAG .
docker build -f docker/Dockerfile.nginx -t $REGISTRY/dr-highkali-web:$TAG .
echo "Built images. Push them with docker push <image>."
DBP
chmod +x scripts/docker_build_push.sh

# 16) Security and compliance placeholders
cat > SECURITY_POLICY.md <<'SEC'
Security policy and incident response:
- Use RBAC and OIDC for access control.
- Maintain audit logs and decision ledger.
- Pen test and vulnerability disclosure process required before production.
SEC

# 17) Git commit
if [ -d .git ]; then
  git add -A
  git commit -m "chore: full dr. HighKali integration bootstrap with containers, k8s, CI, tests" || true
fi

# 18) Seed knowledge base with representative docs
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

# 19) Start services
bash scripts/ghosttrack_termux_start_full.sh

echo "Bootstrap complete."
echo "Open UI at: http://localhost:8000/panels/dr_highkali.html"
echo "API status: http://localhost:9090/api/status"
echo "Metrics: http://localhost:9090/metrics"
echo "Kubernetes manifests in k8s/ for production deploy."
echo "CI workflow in .github/workflows/ci.yml"
echo "DVC placeholders in dvc/"

