#!/usr/bin/env bash
set -e

echo "🚀 Creazione struttura GhostTrack WebApp..."

# 1. Crea cartelle base
mkdir -p webapp/static
mkdir -p api

echo "📁 Cartelle create: webapp/static e api/"

# 2. Sposta UI se esiste docs/
if [ -d docs ]; then
    echo "📦 Sposto UI da docs/ → webapp/static/"
    cp -r docs/* webapp/static/
else
    echo "⚠️ Nessuna cartella docs trovata. UI da ricostruire."
fi

# 3. Crea API Flask
echo "🧠 Creo API Flask..."

cat > api/app.py <<'PY'
from flask import Flask, send_from_directory, jsonify
import pathlib

app = Flask(__name__, static_folder=str(pathlib.Path(__file__).resolve().parents[1] / 'webapp' / 'static'), static_url_path='')

@app.route('/api/status')
def status():
    return jsonify({"status": "ok", "service": "GhostTrack WebApp", "version": "v3"})

@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def serve(path):
    static_path = pathlib.Path(app.static_folder) / path
    if path and static_path.exists():
        return send_from_directory(app.static_folder, path)
    return send_from_directory(app.static_folder, 'index.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8081)
PY

# 4. Requirements
cat > api/requirements.txt <<'REQ'
Flask==2.2.5
gunicorn==20.1.0
REQ

echo "📜 API Flask creata."

# 5. Config JS per UI
cat > webapp/static/config.js <<'CFG'
export const API_BASE = "http://localhost:8081";
CFG

echo "⚙️ config.js creato."

echo "✨ Struttura WebApp completata!"
