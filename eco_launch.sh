#!/usr/bin/env bash
set -e

echo "🌱 Avvio GhostTrack eco-launch..."

# 1. Autenticazione /node/receive
AUTH_TOKEN=$(cat .eco_token)
echo "🔐 Token caricato."

# 2. Packaging automatico
echo "📦 Packaging moduli..."
tar -czf ghosttrack_package.tar.gz webapp/ api/

fi

# 4. Logging automatico
echo "$(date) — eco_launch avviato" >> eco_log.py
echo "📝 Logging registrato in eco_log.py"
