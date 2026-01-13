#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${REPO_ROOT}"

log() {
  printf "\n[GhostTrack][UI] %s\n" "$1"
}

# 1. Verifica repo Git
if [ ! -d ".git" ]; then
  log "Questa directory non è un repository Git."
  exit 1
fi

# 2. Sync webapp/static -> docs
log "Sincronizzo webapp/static/ → docs/ …"

mkdir -p "${REPO_ROOT}/docs"

if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete "${REPO_ROOT}/webapp/static/" "${REPO_ROOT}/docs/"
else
  log "rsync non trovato, uso cp come fallback…"
  rm -rf "${REPO_ROOT}/docs"/*
  cp -r "${REPO_ROOT}/webapp/static/"* "${REPO_ROOT}/docs/" 2>/dev/null || true
fi

# 3. Mostra diff sintetico
log "Stato del repository dopo la sincronizzazione:"
git status --short

# 4. Commit + push
log "Eseguo git add per UI e docs…"
git add webapp/static docs

# Se non ci sono cambiamenti, esco
if git diff --cached --quiet; then
  log "Nessuna modifica da committare."
  exit 0
fi

COMMIT_MSG="${1:-Update dashboard and module panels}"
log "Creo commit: ${COMMIT_MSG}"
git commit -m "${COMMIT_MSG}"

log "Eseguo git push…"
git push

log "Aggiornamento UI completato."
