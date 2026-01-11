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
