#!/data/data/com.termux/files/usr/bin/bash

echo ""
echo "=== GHOSTTRACK — ONE GESTURE ATTACH & SYNC ==="
echo ""

##############################################
# 1. LISTA COMPLETA DEGLI SCRIPT E FILE CHIAVE
##############################################

FILES="
ghosttrack_autogen.sh
ghosttrack_full_ritual.sh
ghosttrack_repair.sh
ghosttrack_telemetry_ritual.sh
ghosttrack_omega_ritual.sh
ghosttrack_menu.sh
ghosttrack.conf
README.md
docs/index.html
docs/telemetry.json
"

##############################################
# 2. AGGIUNTA AUTOMATICA DI TUTTI I FILE
##############################################

echo "[*] Allego tutti gli script e file chiave..."
for f in $FILES; do
    if [ -f "$f" ]; then
        echo " + $f"
        git add "$f"
    else
        echo " - $f (non trovato, salto)"
    fi
done

##############################################
# 3. VERIFICA MODIFICHE
##############################################

CHANGES=$(git diff --cached --name-only)

if [ -z "$CHANGES" ]; then
    echo ""
    echo "[i] Nessuna modifica da committare. Tutto già allineato."
    echo ""
    exit 0
fi

echo ""
echo "[*] File in staging:"
echo "$CHANGES"
echo ""

##############################################
# 4. COMMIT
##############################################

echo "[*] Commit..."
git commit -m "GhostTrack: One-Gesture Attach & Sync"

##############################################
# 5. PUSH
##############################################

echo "[*] Push verso la costellazione..."
git push

echo ""
echo "[✓] One-Gesture Ritual completato."
echo "[✓] Tutti gli script allegati."
echo "[✓] Nodo Pragone sincronizzato."
echo ""
