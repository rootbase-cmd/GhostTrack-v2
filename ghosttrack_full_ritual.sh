#!/data/data/com.termux/files/usr/bin/bash

echo ""
echo "=== GHOSTTRACK FULL RITUAL — CONSTELLATION SYNC ==="
echo ""

# 1. Rigenera l’HTML
./ghosttrack_autogen.sh
if [ $? -ne 0 ]; then
    echo "[!] Errore durante autogen."
    exit 1
fi

# 2. Aggiungi file modificati
git add ghosttrack_autogen.sh docs/index.html README.md ghosttrack.conf

# 3. Commit
git commit -m "GhostTrack: constellation full ritual update"

# 4. Push
git push

echo ""
echo "[✓] Ritual completato."
echo "[✓] Nodo Pragone sincronizzato con la costellazione."
echo ""

