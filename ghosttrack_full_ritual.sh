#!/data/data/com.termux/files/usr/bin/bash

echo "=== GhostTrack Clean ==="
find . -type f \( -name "*.save" -o -name "*~" -o -name "*.swp" -o -name "*.swo" \) -print -delete
echo "[✓] Pulizia completata."
