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
        "dr_highkali": {"description": "AGI orchestratore"},
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
