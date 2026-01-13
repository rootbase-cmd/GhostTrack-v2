#!/usr/bin/env bash
set -e

echo "📡 GhostTrack‑v3 — RITUALE NODO TELEFONO (AUTO‑DEPLOY)"
echo

cd "$HOME/GhostTrack-v2" || { echo "❌ Repo non trovata"; exit 1; }

echo "🔍 Rilevo IP pubblico del telefono..."
PUBLIC_IP=$(curl -s ifconfig.me)
echo "   ✔ IP pubblico: $PUBLIC_IP"
echo

echo "🧠 Aggiorno config.json per usare il telefono come server..."
cat > webapp/static/config.json << EOF
{
  "mode": "prod",
  "base_url_dev": "http://127.0.0.1:9090",
  "base_url_prod": "http://$PUBLIC_IP:9090"
}
EOF
echo "   ✔ config.json aggiornato"
echo

echo "📂 Copio la WebApp in /docs per GitHub Pages..."
mkdir -p docs
cp -r webapp/static/* docs/
echo "   ✔ UI sincronizzata in docs/"
echo

echo "📝 Commit & Push su GitHub..."
git add docs/ webapp/static/config.json
git commit -m "GhostTrack‑v3: deploy automatico nodo telefono ($PUBLIC_IP)"
git push
echo "   ✔ Pubblicato su GitHub"
echo

echo "🚀 Avvio API GhostTrack sul telefono..."
echo "   (Premi CTRL+C per fermare il server)"
echo
python api/app.py --host 0.0.0.0 --port 9090
