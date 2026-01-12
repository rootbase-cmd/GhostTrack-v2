#!/data/data/com.termux/files/usr/bin/bash

echo "[GHOSTTRACK] Avvio rituale globale…"

# 1. Struttura
mkdir -p docs/assets
mkdir -p docs/maps

# 2. Aggiorna script JS
if [ -f ghosttrack_hub.js ]; then
    cp ghosttrack_hub.js docs/assets/ghosttrack_hub.js
    echo "[OK] Script JS aggiornato"
fi

# 3. Aggiorna mappe offline
if [ -d maps ]; then
    cp -r maps/* docs/maps/
    echo "[OK] Mappe offline aggiornate"
fi

# 4. Aggiorna index.html
if [ -f index.html ]; then
    cp index.html docs/index.html
    echo "[OK] index.html aggiornato"
fi

# 5. Git add
git add docs/assets/ghosttrack_hub.js 2>/dev/null
git add docs/maps 2>/dev/null
git add docs/index.html 2>/dev/null

# 6. Commit
git commit -m "GhostTrack Global Ritual: update hub, maps, tools" 2>/dev/null

# 7. Push
git push origin main

echo "[GHOSTTRACK] Rituale completato."
echo "Hub aggiornato: https://highkali.github.io/GhostTrack-v2/"
