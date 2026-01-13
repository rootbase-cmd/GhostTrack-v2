#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/GhostTrack-v2"
TMP="$ROOT/tmp"
[ -f "$TMP/gt_http_server.pid" ] && kill "$(cat $TMP/gt_http_server.pid)" 2>/dev/null || true
[ -f "$TMP/gt_api.pid" ] && kill "$(cat $TMP/gt_api.pid)" 2>/dev/null || true
echo "Stopped services"
