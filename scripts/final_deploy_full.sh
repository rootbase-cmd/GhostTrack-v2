#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
mkdir -p .logs
# stop old services
for f in .logs/*.pid; do [ -f "$f" ] && kill $(cat "$f") 2>/dev/null || true; done
sleep 1
# start static server
cd docs
nohup python3 -m http.server 8080 > ../.logs/local_server.log 2>&1 &
echo $! > ../.logs/local_server.pid
cd "$ROOT"
# start wallet_api
nohup python3 server/wallet_api.py > .logs/wallet_api.log 2>&1 &
echo $! > .logs/wallet_api.pid
sleep 1
# start orchestrator if exists
if [ -f agents/orchestrator.py ]; then
  nohup python3 agents/orchestrator.py > .logs/orchestrator.log 2>&1 &
  echo $! > .logs/orchestrator.pid
fi
sleep 1
# start economist
nohup python3 agents/economist.py > .logs/economist.log 2>&1 &
echo $! > .logs/economist.pid
sleep 2
echo "Services started. Check .logs/*.log"
