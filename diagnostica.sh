#!/usr/bin/env bash
echo "🔍 DIAGNOSTICA GHOSTTRACK v3 — COMPLETA"; echo;

echo "🛡️ 1) Difesa informatica — file sensibili:"
for f in .eco_token eco_log.py; do
  [ -f "$f" ] && echo "   ✔ $f presente" || echo "   ✖ $f MANCANTE"
done
echo;

echo "🖥️ 2) UI — config.json:"
if [ -f webapp/static/config.json ]; then
  echo "   ✔ config.json presente"
  grep -q "\"starlink_control\": true" webapp/static/config.json && echo "   ✔ modulo Starlink attivo" || echo "   ✖ modulo Starlink NON attivo"
  grep -q "\"podcast_liberi\": true" webapp/static/config.json && echo "   ✔ modulo Podcast attivo" || echo "   ✖ modulo Podcast NON attivo"
  grep -q "\"economist\": true" webapp/static/config.json && echo "   ✔ modulo Economist attivo" || echo "   ✖ modulo Economist NON attivo"
else
  echo "   ✖ config.json MANCANTE"
fi
echo;

echo "📦 3) UI — pannelli:"
PANNELLI=(dashboard economist orchestrator wallet podcast_liberi starlink_control settings)
for p in "${PANNELLI[@]}"; do
  [ -f "webapp/static/panels/$p.html" ] && echo "   ✔ pannello $p" || echo "   ✖ pannello $p MANCANTE"
done
echo;

echo "🔌 4) API — struttura:"
for f in api/app.py api/requirements.txt; do
  [ -f "$f" ] && echo "   ✔ $f presente" || echo "   ✖ $f MANCANTE"
done
echo;

echo "🌐 5) API — test endpoint locali:"
ENDPOINTS=(
  "/api/status"
  "/api/starlink/status"
  "/api/economist/summary"
  "/api/wallet/summary"
  "/api/podcast/list"
)
for ep in "${ENDPOINTS[@]}"; do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:9090$ep")
  echo "   $ep → HTTP $CODE"
done
echo;

echo "⚡ 6) Crediti energetici:"
grep -q "\"credits\"" api/app.py && echo "   ✔ endpoint crediti presente" || echo "   ✖ endpoint crediti MANCANTE"
grep -q "\"total_credits\"" api/app.py && echo "   ✔ economist attivo" || echo "   ✖ economist NON attivo"
echo;

echo "🛰️ 7) Starlink:"
grep -q "\"latency_ms\"" api/app.py && echo "   ✔ telemetria presente" || echo "   ✖ telemetria MANCANTE"
grep -q "\"mode\"" api/app.py && echo "   ✔ modalità Starlink presente" || echo "   ✖ modalità MANCANTE"
echo;

echo "🚀 8) Deploy — render.yaml:"
[ -f render.yaml ] && echo "   ✔ render.yaml presente" || echo "   ✖ render.yaml MANCANTE"
echo;

echo "🌱 9) eco_launch.sh:"
[ -f eco_launch.sh ] && echo "   ✔ eco_launch.sh presente" || echo "   ✖ eco_launch.sh MANCANTE"

echo; echo "✨ Diagnostica completata."
