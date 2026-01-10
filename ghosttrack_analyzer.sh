#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
ROOT="$HOME/GhostTrack-v2"
DOCS="$ROOT/docs"
echo "=== PATH ==="
echo "ROOT: $ROOT"
echo
echo "=== GIT STATUS ==="
cd "$ROOT"
git status --porcelain || true
git remote -v || true
git log -1 --pretty=oneline || true
echo
echo "=== FILES EXISTENCE ==="
for f in "$DOCS" "$DOCS/index.html" "$DOCS/assets/js/ghosttrack.js" "$DOCS/assets/css/ghosttrack.css" "$DOCS/telemetry.json"; do
  if [ -e "$f" ]; then echo "OK: $f"; else echo "MISSING: $f"; fi
done
echo
echo "=== INDEX CHECK (markers) ==="
grep -nE 'id=\"menuButton\"|id=\"menuPanel\"|assets/js/ghosttrack.js|assets/css/ghosttrack.css' "$DOCS/index.html" || echo "Markers non trovati"
echo
echo "=== TELEMETRY JSON VALIDATION ==="
if python3 -m json.tool "$DOCS/telemetry.json" >/dev/null 2>&1; then echo "telemetry.json: VALID"; else echo "telemetry.json: INVALID"; fi
echo
echo "=== SCRIPTS PERMESSI ==="
for s in ghosttrack_super_complete.sh ghosttrack_super_sync.sh ghosttrack_menu.sh; do
  if [ -f "$ROOT/$s" ]; then ls -l "$ROOT/$s"; else echo "No $s"; fi
done
echo
echo "=== LAST 200 LINES OF SERVER LOG (if running) ==="
ps aux | grep -E 'http.server|python3 -m http.server' | grep -v grep || echo "Server non trovato"
echo
echo "=== END REPORT ==="
