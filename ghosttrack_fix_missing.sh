#!/usr/bin/env bash
set -e

echo "🔧 Rigenerazione README.md e eco_log.py..."

# README.md corretto
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
echo "📝 eco_log.py creato."

echo "✨ Fix completato."
