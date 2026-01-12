#!/data/data/com.termux/files/usr/bin/bash

echo ""
echo "=== GHOSTTRACK REPAIR RITUAL — REPO SANITIZATION ==="
echo ""

# 1. Rimozione file di backup e temporanei
echo "[*] Pulizia file temporanei e backup..."
find . -type f \( \
    -name "*.save" -o \
    -name "*~" -o \
    -name "*.tmp" -o \
    -name "*.swp" -o \
    -name "*.swo" -o \
    -name ".DS_Store" \
\) -print -delete

# 2. Rimozione file non tracciati opzionali (solo se sicuri)
echo ""
echo "[*] Rimozione file non tracciati noti..."
UNTRACKED=$(git ls-files --others --exclude-standard)
if [ -n "$UNTRACKED" ]; then
    echo "$UNTRACKED" | while read FILE; do
        case "$FILE" in
            *.log|*.bak|*.old)
                echo " - Rimuovo $FILE"
                rm -f "$FILE"
                ;;
        esac
    done
else
    echo "Nessun file non tracciato rilevante."
fi

# 3. Ripristino permessi corretti sugli script
echo ""
echo "[*] Ripristino permessi sugli script..."
chmod +x ghosttrack_autogen.sh 2>/dev/null
chmod +x ghosttrack_full_ritual.sh 2>/dev/null
chmod +x ghosttrack_clean.sh 2>/dev/null
chmod +x ghosttrack_repair.sh 2>/dev/null

# 4. Verifica integrità Git
echo ""
echo "[*] Stato Git dopo la pul
