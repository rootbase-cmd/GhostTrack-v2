#!/usr/bin/env bash
set -e

echo "🚀 Generazione completa: deploy, launcher, README, logging, roadmap..."

# 1. render.yaml
cat > render.yaml <<'YAML'
services:
  - type: web
    name: ghosttrack-api
    env: python
    buildCommand: pip install -r api/requirements.txt
    startCommand: gunicorn -w 4 -b 0.0.0.0:10000 app:app
    plan: free
YAML
echo "✅ render.yaml creato."

# 2. eco_launch.sh
cat > eco_launch.sh <<'SH'
#!/usr/bin/env bash
set -e

echo "🌱 Avvio GhostTrack eco-launch..."

# 1. Autenticazione /node/receive
AUTH_TOKEN=$(cat .eco_token)
echo "🔐 Token caricato."

# 2. Packaging automatico
echo "📦 Packaging moduli..."
tar -czf ghosttrack_package.tar.gz webapp/ api/

# 3. Notifica Telegram
if [ -f .telegram_hook ]; then
  HOOK=$(cat .telegram_hook)
  curl -s -X POST "$HOOK" -d "GhostTrack eco_launch avviato: $(date)"
  echo "📨 Notifica Telegram inviata."
fi

# 4. Logging automatico
echo "$(date) — eco_launch avviato" >> eco_log.py
echo "📝 Logging registrato in eco_log.py"
SH
chmod +x eco_launch.sh
echo "✅ eco_launch.sh creato."

# 3. README.md
cat > README.md <<'MD'
# GhostTrack v3 — Operational Console

GhostTrack è una costellazione modulare di nodi osservatori, con UI dark, API Flask, e pannelli reali per Starlink, Podcast, Wallet, Economist e Orchestrator.

## Moduli attivi

- 📡 Dashboard  
- 📈 Economist  
- 🧭 Orchestrator  
- 💳 Wallet  
- 🎵 Podcast liberi  
- 🛰️ Starlink Control  
- ⚙️ Impostazioni

## Deploy

- UI: GitHub Pages → `webapp/static/`
- API: Render → `api/`

## Avvio

```bash
bash eco_launch.sh

echo "# eco_log.py — logging automatico" > eco_log.py
echo "✅ eco_log.py creato."

echo "✨ Tutti i 9 punti generati."
