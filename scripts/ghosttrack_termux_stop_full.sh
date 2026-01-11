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
