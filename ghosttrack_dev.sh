#!/data/data/com.termux/files/usr/bin/bash

cd ~/GhostTrack-v2 || exit

echo "[GhostTrack Dev] Controllo modifiche..."
git status

echo
echo "[GhostTrack Dev] Aggiungo file modificati..."
git add .

echo
echo "[GhostTrack Dev] Commit..."
git commit -m "Dev update: $(date '+%Y-%m-%d %H:%M:%S')"

echo
echo "[GhostTrack Dev] Push su GitHub..."
git push origin main

echo
echo "[GhostTrack Dev] Completato."

