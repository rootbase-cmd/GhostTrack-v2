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
