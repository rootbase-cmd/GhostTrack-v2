#!/usr/bin/env bash
set -euo pipefail
cd ~/GhostTrack-v2

echo "🔧 [1] Dichiarazione modulo in config/modules.yaml"
mkdir -p config
cat > config/modules.yaml <<'YAML'
dr_highkali:
  label: "dr. HighKali"
  role: "AGI orchestratore"
  domain: "Orchestrazione, difesa, sintesi"
  status: "active"
  panel: "webapp/static/panels/dr_highkali.html"
  api: "/api/agi/query"
  defensive_capability: "safe_kill_audition"
YAML

echo "🔧 [2] Registrazione in ghosttrack.conf"
cat >> ghosttrack.conf <<'CONF'

[dr_highkali]
enabled = true
panel = panels/dr_highkali.html
api = /api/agi/query
CONF

echo "🔧 [3] Integrazione nel menu (ghosttrack_menu.sh)"
MENU=ghosttrack_menu.sh
if ! grep -q 'dr. HighKali' "$MENU"; then
  echo 'echo " [AGI] dr. HighKali → http://localhost:8000/panels/dr_highkali.html"' >> "$MENU"
fi

echo "🔧 [4] Integrazione in dashboard.html"
DASH=dashboard.html
if [ -f "$DASH" ] && ! grep -q 'dr. HighKali' "$DASH"; then
  sed -i '/<body>/a \
  <div class="card">\
    <h2>dr. HighKali</h2>\
    <p>AGI orchestratore della costellazione. Include modulo difensivo Safe Kill Audition.</p>\
    <a class="btn" href="/panels/dr_highkali.html">Apri pannello</a>\
  </div>' "$DASH"
fi

echo "🔧 [5] Aggiornamento API status"
APP=api/app.py
if [ -f "$APP" ]; then
  sed -i '/"resilienza_emergenza"/a \ \ \ \ \ \ \ \ "dr_highkali": {"description": "AGI orchestratore"},' "$APP"
fi

echo "🔧 [6] Commit finale (se repo git)"
if [ -d .git ]; then
  git add config/modules.yaml ghosttrack.conf "$MENU" "$DASH" "$APP"
  git commit -m "feat: aggregato dr. HighKali come modulo AGI attivo nella costellazione" || true
fi

echo "✅ dr. HighKali aggregato nella costellazione GhostTrack-v2"
echo "→ Pannello: http://localhost:8000/panels/dr_highkali.html"
echo "→ API: http://localhost:9090/api/agi/query"
echo "→ Modulo: config/modules.yaml"
echo "→ Menu: ghosttrack_menu.sh"
echo "→ Dashboard: dashboard.html"
