#!/data/data/com.termux/files/usr/bin/bash

echo ""
echo "=============================="
echo "  GHOSTTRACK AUTO‑FIX RITUAL"
echo "=============================="
echo ""

# 1. Assicura struttura corretta
echo "[1] Verifica struttura..."
mkdir -p docs/assets
mkdir -p docs/maps

# 2. Se esiste index.html nella root → è quello sbagliato → lo copia in docs/
if [ -f index.html ]; then
    echo "[2] Trovato index.html nella root → correzione automatica"
    cp index.html docs/index.html
else
    echo "[2] Nessun index.html nella root → ok"
fi

# 3. Se esiste ghosttrack_hub.js nella root → copia nella posizione corretta
if [ -f ghosttrack_hub.js ]; then
    echo "[3] Aggiornamento script JS..."
    cp ghosttrack_hub.js docs/assets/ghosttrack_hub.js
else
    echo "[3] Nessuno script JS nella root → ok"
fi

# 4. Se esiste cartella maps nella root → copia in docs/maps
if [ -d maps ]; then
    echo "[4] Aggiornamento mappe offline..."
    cp -r maps/* docs/maps/
else
    echo "[4] Nessuna cartella maps nella root → ok"
fi

# 5. Git add
echo "[5] Aggiunta file a Git..."
git add docs/index.html 2>/dev/null
git add docs/assets/ghosttrack_hub.js 2>/dev/null
git add docs/maps 2>/dev/null

# 6. Commit
echo "[6] Commit..."
git commit -m "GhostTrack AutoFix: sync index, scripts, maps" 2>/dev/null

# 7. Push
echo "[7] Push su GitHub..."
git push origin main

echo ""
echo "=============================="
echo "  RITUALE COMPLETATO"
echo "=============================="
echo ""
echo "GhostTrack Hub aggiornato:"
echo "https://highkali.github.io/GhostTrack-v2/"
echo ""
