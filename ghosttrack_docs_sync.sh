#!/usr/bin/env bash
set -e

echo "📚 GhostTrack‑v2 — RITUALE DOCUMENTAZIONE & SYNC"
echo

cd "$HOME/GhostTrack-v2" || { echo "❌ Repo non trovata"; exit 1; }
echo "📁 Root repo: $(pwd)"
echo

# 1) Proteggi file sensibili
echo "🔐 Aggiornamento .gitignore per file sensibili..."
touch .gitignore
grep -qxF ".eco_token" .gitignore || echo ".eco_token" >> .gitignore
grep -qxF "eco_log.py" .gitignore || echo "eco_log.py" >> .gitignore
echo "   ✔ File sensibili protetti"
echo

# 2) Assicurati che la cartella docs esista
mkdir -p docs

echo "📘 Allineamento file documentazione (README + docs/)..."
# (I file sono già stati creati manualmente con i cat nel terminale)
# Qui ci limitiamo ad aggiungerli a Git.

git add README.md 2>/dev/null || true
git add docs/INDEX.md 2>/dev/null || true
git add docs/EXECUTIVE_REPORT.md 2>/dev/null || true
git add docs/ROADMAP.md 2>/dev/null || true
git add docs/ABOUT_PAGE.md 2>/dev/null || true
echo "   ✔ File documentazione aggiunti allo staging"
echo

# 3) Commit se necessario
if git diff --cached --quiet; then
  echo "ℹ️ Nessuna modifica documentale da committare."
else
  echo "📝 Creazione commit documentazione..."
  git commit -m "Docs: README ufficiale + Wiki tecnica + Executive + Roadmap + About"
  echo "   ✔ Commit documentazione creato"
fi
echo

# 4) Push
echo "🌍 Push su GitHub..."
git push
echo "   ✔ Push completato"
echo

echo "✨ Documentazione GhostTrack‑v2 ora allineata e pubblicata."
