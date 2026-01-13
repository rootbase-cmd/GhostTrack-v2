#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
mkdir -p .logs
echo "[$(date)] Avvio server locale" >> .logs/local_server.log
cd docs
python3 -m http.server 8080 >> ../.logs/local_server.log 2>&1 &
echo $! > ../.logs/local_server.pid
echo "Server avviato su http://localhost:8080/ (PID $(cat ../.logs/local_server.pid))"
