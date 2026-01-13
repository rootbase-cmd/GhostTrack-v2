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
