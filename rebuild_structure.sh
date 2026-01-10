#!/usr/bin/env bash
set -e

echo "🔧 Ricostruzione completa struttura GhostTrack WebApp..."

# 1. Crea cartelle base
mkdir -p webapp/static
mkdir -p api

echo "📁 Cartelle create: webapp/static e api/"

# 2. Crea un index.html minimale se non esiste
if [ ! -f webapp/static/index.html ]; then
    cat > webapp/static/index.html <<'HTML'
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>GhostTrack WebApp</title>
</head>
<body>
  <h1>GhostTrack WebApp</h1>
  <p>UI ricostruita. Collegamento API in corso...</p>
  <script type="module" src="config.js"></script>
</body>
</html>
HTML
    echo "📝 index.html creato."
fi

# 3. Crea config.js
cat > webapp/static/config.js <<'CFG'
export const API_BASE = "http://127.0.0.1:9090";
CFG

echo "⚙️ config.js creato."

# 4. Crea API Flask
cat > api/app.py <<'PY'
from flask import Flask, send_from_directory, jsonify
import pathlib

STATIC_DIR = pathlib.Path(__file__).resolve().parents[1] / "webapp" / "static"

app = Flask(
    __name__,
    static_folder=str(STATIC_DIR),
    static_url_path=""
)

@app.route("/api/status")
def status():
    return jsonify({
        "status": "ok",
        "service": "GhostTrack WebApp",
        "version": "v3"
    })

@app.route("/", defaults={"path": ""})
@app.route("/<path:path>")
def serve(path):
    target = STATIC_DIR / path
    if path and target.exists():
        return send_from_directory(STATIC_DIR, path)
    return send_from_directory(STATIC_DIR, "index.html")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=9090)
PY

echo "🧠 app.py ricreato."

# 5. Requirements
cat > api/requirements.txt <<'REQ'
Flask==2.2.5
gunicorn==20.1.0
REQ

echo "📦 requirements.txt creato."

echo "✨ Ricostruzione completata!"
