#!/data/data/com.termux/files/usr/bin/bash

echo ""
echo "=== GHOSTTRACK — ONE GESTURE ATTACH & SYNC (FULL REPO) ==="
echo ""

FILES="
ghosttrack_autogen.sh
ghosttrack_full_ritual.sh
ghosttrack_repair.sh
ghosttrack_telemetry_ritual.sh
ghosttrack_attach_all.sh
ghosttrack_super_commit.sh
ghosttrack_autofix.sh
ghosttrack_html_sync.sh
ghosttrack_menu.sh
ghosttrack_global.sh
ghost_bootstrap.sh
ghosttrack.conf
README.md
SECURITY.md
docs/index.html
docs/telemetry.json
"

echo "[*] Allego tutti gli script e file chiave..."
for f in $FILES; do
    if [ -f "$f" ]; then
        echo " + $f"
        git add "$f"
    else
        echo " - $f (non trovato)"
    fi
done

echo ""
echo "[*] Allego directory operative..."
git add config core modules ops system tools var logs manifest

echo ""
CHANGES=$(git diff --cached --name-only)

if [ -z "$CHANGES" ]; then
    echo "[i] Nessuna modifica da committare."
    exit 0
fi

echo "[*] File in staging:"
echo "$CHANGES"
echo ""

echo "[*] Commit..."
git commit -m "GhostTrack: One-Gesture Full Repo Sync"

echo "[*] Push..."
git push

echo ""
echo "[✓] One-Gesture Sync COMPLETATO."
echo "[✓] Repo completamente aggiornata."
echo "[✓] Nodo Pragone allineato alla costellazione."
echo ""
