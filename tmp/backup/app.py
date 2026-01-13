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
