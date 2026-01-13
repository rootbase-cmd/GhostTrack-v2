#!/data/data/com.termux/files/usr/bin/bash

echo ""
echo "=== GHOSTTRACK TELEMETRY RITUAL — NODE PRAGONE ==="
echo ""

# 1. Raccolta telemetria locale
echo "[*] Raccolgo telemetria locale..."

NODE_NAME="Pragone Node"
NODE_LOCATION="Pragone, Pietra de’ Giorgi, IT"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
UPTIME=$(uptime -p 2>/dev/null || echo "n/a")
LOADAVG=$(cat /proc/loadavg 2>/dev/null | awk '{print $1" "$2" "$3}' || echo "n/a")
DISK=$(df -h . 2>/dev/null | awk 'NR==2 {print $5" used ("$4" free)"}' || echo "n/a")
IP_ADDR=$(ip addr show 2>/dev/null | grep "inet " | grep -v "127.0.0.1" | head -n1 | awk '{print $2}' || echo "n/a")

# 2. Scrivo telemetria in un file JSON (docs/telemetry.json)
echo "[*] Aggiorno docs/telemetry.json..."

cat > docs/telemetry.json <<EOF
{
  "node_name": "$NODE_NAME",
  "location": "$NODE_LOCATION",
  "timestamp_utc": "$TIMESTAMP",
  "uptime": "$UPTIME",
  "loadavg": "$LOADAVG",
  "disk_usage": "$DISK",
  "ip_address": "$IP_ADDR",
  "status": "online",
  "heartbeat": true
}
EOF

echo "[✓] Telemetria locale aggiornata in docs/telemetry.json"
echo ""

# 3. Rigenero il sito
echo "[*] Lancio ghosttrack_autogen.sh..."
./ghosttrack_autogen.sh
if [ $? -ne 0 ]; then
    echo "[!] Errore durante autogen. Interrompo il rituale."
    exit 1
fi

# 4. Aggiungo telemetria e sito al commit
echo "[*] Aggiungo telemetria e sito allo staging..."
git add docs/telemetry.json docs/index.html

# 5. Aggiungo anche script e config chiave
git add \
  ghosttrack_autogen.sh \
  ghosttrack_full_ritual.sh \
  ghosttrack_telemetry_ritual.sh \
  ghosttrack_repair.sh \
  ghosttrack.conf \
  README.md

# 6. Verifico se ci sono modifiche reali
CHANGES=$(git diff --cached --name-only)
if [ -z "$CHANGES" ]; then
    echo ""
    echo "[i] Nessuna modifica da committare. Telemetria invariata, costellazione già allineata."
    echo ""
    exit 0
fi

echo ""
echo "[*] File in staging:"
echo "$CHANGES"
echo ""

# 7. Commit
echo "[*] Commit telemetria + sito..."
git commit -m "GhostTrack: telemetry ritual update"

# 8. Push
echo "[*] Push verso la costellazione (origin/main)..."
git push

echo ""
echo "[✓] Telemetry ritual completato."
echo "[✓] Nodo Pragone aggiornato, heartbeat inviato alla costellazione."
echo ""
