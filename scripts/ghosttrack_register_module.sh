#!/usr/bin/env bash
set -euo pipefail

# Parametri
MOD_ID="${1:-}"
MOD_LABEL="${2:-}"
MOD_ROLE="${3:-}"
MOD_PANEL="${4:-}"
MOD_API="${5:-}"
MOD_DOMAIN="${6:-}"
MOD_DEFENSE="${7:-}"

if [ -z "$MOD_ID" ] || [ -z "$MOD_LABEL" ]; then
  echo "Uso: $0 <id> <label> [role] [panel] [api] [domain] [defensive_capability]"
  exit 1
fi

cd ~/GhostTrack-v2

echo "🔧 Registrazione modulo: $MOD_ID"

# 1. modules.yaml
mkdir -p config
MODFILE=config/modules.yaml
touch "$MODFILE"
yq eval ".${MOD_ID} = {
  label: \"$MOD_LABEL\",
  role: \"$MOD_ROLE\",
  domain: \"$MOD_DOMAIN\",
  status: \"active\",
  panel: \"$MOD_PANEL\",
  api: \"$MOD_API\",
  defensive_capability: \"$MOD_DEFENSE\"
}" -i "$MODFILE"

# 2. ghosttrack.conf
CONF=ghosttrack.conf
echo -e "\n[$MOD_ID]\nenabled = true\npanel = $MOD_PANEL\napi = $MOD_API" >> "$CONF"

# 3. Menu
MENU=ghosttrack_menu.sh
if ! grep -q "$MOD_LABEL" "$MENU"; then
  echo "echo \" [$MOD_ID] $MOD_LABEL → http://localhost:8000/$MOD_PANEL\"" >> "$MENU"
fi

# 4. Dashboard
DASH=dashboard.html
if [ -f "$DASH" ] && ! grep -q "$MOD_LABEL" "$DASH"; then
  sed -i "/<body>/a \
  <div class='card'>\
    <h2>$MOD_LABEL</h2>\
    <p>$MOD_ROLE — $MOD_DOMAIN</p>\
    <a class='btn' href='/$MOD_PANEL'>Apri pannello</a>\
  </div>" "$DASH"
fi

# 5. API status
APP=api/app.py
if [ -f "$APP" ]; then
  sed -i "/resilienza_emergenza/a \ \ \ \ \ \ \ \ \"$MOD_ID\": {\"description\": \"$MOD_LABEL\"}," "$APP"
fi

# 6. Commit
if [ -d .git ]; then
  git add "$MODFILE" "$CONF" "$MENU" "$DASH" "$APP"
  git commit -m "feat: registrato modulo $MOD_ID ($MOD_LABEL) nella costellazione" || true
fi

echo "✅ Modulo $MOD_ID registrato."
