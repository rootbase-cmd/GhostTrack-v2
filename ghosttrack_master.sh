#!/data/data/com.termux/files/usr/bin/bash

echo ""
echo "=== GHOSTTRACK MASTER RITUAL — TOTAL A→Z SYNC ==="
echo ""

##############################################
# 1. REPAIR
##############################################
echo "[1/7] Risanamento repository..."
./ghosttrack_repair.sh

##############################################
# 2. TELEMETRIA
##############################################
echo "[2/7] Raccolta telemetria..."
./ghosttrack_telemetry_ritual.sh --no-commit

##############################################
# 3. AUTOGEN
##############################################
echo "[3/7] Rigenerazione interfaccia..."
./ghosttrack_autogen.sh

##############################################
# 4. ATTACH ALL (AGGIUNGE TUTTI GLI SCRIPT E DIRECTORY)
##############################################
echo "[4/7] Allego l'intera struttura GhostTrack..."
./ghosttrack_attach_all.sh --no-commit

##############################################
# 5. SUPER COMMIT (COMMIT UNICO)
##############################################
echo "[5/7] Commit unico dell'intero nodo..."
git add -A
git commit -m "GhostTrack Master Ritual — Full A→Z Sync"

##############################################
# 6. PUSH
##############################################
echo "[6/7] Push verso la costellazione..."
git push

##############################################
# 7. CHIUSURA
##############################################
echo ""
echo "[✓] Master Ritual completato."
echo "[✓] Nodo Pragone completamente sincronizzato."
echo "[✓] Telemetria aggiornata."
echo "[✓] Interfaccia rigenerata."
echo "[✓] Repo allineata."
echo "[✓] Costellazione aggiornata."
echo ""
