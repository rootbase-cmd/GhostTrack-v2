#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${REPO_ROOT}/.venv"
PYTHON_BIN="python3"

log() {
  printf "\n[GhostTrack] %s\n" "$1"
}

warn() {
  printf "\n[GhostTrack][WARN] %s\n" "$1" >&2
}

fail() {
  printf "\n[GhostTrack][ERROR] %s\n" "$1" >&2
  exit 1
}

check_environment() {
  log "Analisi ambiente…"

  if ! command -v "${PYTHON_BIN}" >/dev/null 2>&1; then
    fail "Python3 non trovato. Installa python3 e riprova."
  fi

  if ! command -v pip >/dev/null 2>&1; then
    fail "pip non trovato. Installa pip per Python3 e riprova."
  fi

  if ! command -v git >/dev/null 2>&1; then
    warn "git non trovato. Alcuni step di versione/coerenza saranno saltati."
  fi
}

setup_venv() {
  log "Preparazione virtualenv…"

  if [ ! -d "${VENV_DIR}" ]; then
    "${PYTHON_BIN}" -m venv "${VENV_DIR}"
  fi

  # shellcheck disable=SC1091
  source "${VENV_DIR}/bin/activate"

  if [ -f "${REPO_ROOT}/requirements.txt" ]; then
    log "Installazione dipendenze da requirements.txt…"
    pip install --upgrade pip
    pip install -r requirements.txt
  else
    log "requirements.txt non trovato, installo pacchetti minimi…"
    pip install --upgrade pip
    pip install flask flask_cors
  fi
}

clean_caches() {
  log "Pulizia cache e artefatti…"

  find "${REPO_ROOT}" -name "__pycache__" -type d -prune -exec rm -rf {} +
  find "${REPO_ROOT}" -name "*.pyc" -delete
  find "${REPO_ROOT}" -name "*.pyo" -delete

  if [ -d "${REPO_ROOT}/docs" ]; then
    find "${REPO_ROOT}/docs" -name ".DS_Store" -delete || true
  fi
}

regenerate_ui_and_docs() {
  log "Rigenerazione UI e documentazione…"

  if [ -d "${REPO_ROOT}/webapp/static" ]; then
    mkdir -p "${REPO_ROOT}/docs"
    rsync -a --delete "${REPO_ROOT}/webapp/static/" "${REPO_ROOT}/docs/"
  fi

  if [ -x "${REPO_ROOT}/tools/build_docs.sh" ]; then
    log "Eseguo tools/build_docs.sh…"
    "${REPO_ROOT}/tools/build_docs.sh"
  fi
}

check_consistency() {
  log "Analisi di coerenza del sistema…"

  local ok=true

  if [ ! -f "${REPO_ROOT}/api/app.py" ]; then
    warn "api/app.py mancante: API Flask non trovata."
    ok=false
  fi

  if [ ! -d "${REPO_ROOT}/webapp" ]; then
    warn "cartella webapp mancante: UI non trovata."
    ok=false
  fi

  if [ ! -f "${REPO_ROOT}/webapp/static/config.json" ]; then
    warn "webapp/static/config.json mancante."
    ok=false
  fi

  if [ -f "${REPO_ROOT}/api/app.py" ]; then
    log "Verifico che l’API sia importabile…"
    if ! "${VENV_DIR}/bin/python" -c "import sys; sys.path.append('${REPO_ROOT}/api'); import app" >/dev/null 2>&1; then
      warn "L’API non è importabile senza errori. Controlla api/app.py."
      ok=false
    fi
  fi

  if [ "${ok}" = false ]; then
    warn "Coerenza parziale: alcune componenti mancano o hanno warning. Continuo, ma il sistema potrebbe non essere completo."
  else
    log "Coerenza di base OK."
  fi
}

start_api() {
  log "Avvio API GhostTrack…"

  # shellcheck disable=SC1091
  source "${VENV_DIR}/bin/activate"

  cd "${REPO_ROOT}/api"

  API_PORT="${API_PORT:-9090}"
  API_HOST="${API_HOST:-0.0.0.0}"

  log "Eseguo: python app.py --host ${API_HOST} --port ${API_PORT}"
  exec python app.py --host "${API_HOST}" --port "${API_PORT}"
}

main() {
  log "Rituale completo GhostTrack: analisi → riparazione → pulizia → rigenerazione → coerenza → avvio"

  check_environment
  setup_venv
  clean_caches
  regenerate_ui_and_docs
  check_consistency
  start_api
}

main "$@"
