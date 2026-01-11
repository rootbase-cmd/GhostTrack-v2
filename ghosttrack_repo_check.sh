#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo
echo "=== GhostTrack Repo Quick Check ==="
echo "Root: $ROOT"
echo

check() {
  local path="$1"; local desc="$2"
  if [ -e "$ROOT/$path" ]; then
    printf "OK  %-40s %s\n" "$desc" "$path"
  else
    printf "MISSING %-40s %s\n" "$desc" "$path"
    MISSING=1
  fi
}

MISSING=0

# Basic structure
check "webapp/static" "Static assets folder"
check "webapp/static/panels" "Panels folder"
check "webapp/static/panels/dashboard.html" "Dashboard HTML"
check "webapp/static/app.js" "Front-end JS (app.js)"
check "webapp/static/sensors.json" "Sensors registry (sensors.json)"
check "docs" "Docs folder (GitHub Pages output)"
check "docs/index.html" "Docs index (redirect)"
check ".github/workflows/gh-pages.yml" "GitHub Actions workflow"
check "api" "API folder"
check "api/app.py" "API entrypoint (app.py) or equivalent"
check "README.md" "Repository README"

echo
# Git status quick checks
if command -v git >/dev/null 2>&1 && [ -d "$ROOT/.git" ]; then
  echo "Git repository detected."
  cd "$ROOT"
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
  ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
  dirty=$(git status --porcelain 2>/dev/null || echo "")
  echo "  Branch: $branch"
  [ "$ahead" != "0" ] && echo "  Commits local not pushed: $ahead"
  if [ -n "$dirty" ]; then
    echo "  Working tree: has uncommitted changes"
  else
    echo "  Working tree: clean"
  fi
else
  echo "No git repository detected or git not available."
fi

echo
# JSON validation (if jq available)
if command -v jq >/dev/null 2>&1; then
  if [ -f "$ROOT/webapp/static/sensors.json" ]; then
    echo "Validating sensors.json..."
    if jq empty "$ROOT/webapp/static/sensors.json" 2>/dev/null; then
      echo "  sensors.json: valid JSON"
    else
      echo "  sensors.json: INVALID JSON"
      MISSING=1
    fi
  fi
  if [ -f "$ROOT/webapp/static/config.json" ]; then
    echo "Validating config.json..."
    if jq empty "$ROOT/webapp/static/config.json" 2>/dev/null; then
      echo "  config.json: valid JSON"
    else
      echo "  config.json: INVALID JSON"
      MISSING=1
    fi
  fi
else
  echo "jq not installed: skipping JSON validation (install jq to enable)."
fi

echo
# Quick content checks
if [ -f "$ROOT/webapp/static/panels/dashboard.html" ]; then
  if grep -q "api_base_url" "$ROOT/webapp/static/panels/dashboard.html" 2>/dev/null; then
    echo "Dashboard: contains api_base_url reference (good)"
  else
    echo "Dashboard: no explicit api_base_url reference found (check config.json or inline settings)"
  fi
fi

# Workflow presence check
if [ -f "$ROOT/.github/workflows/gh-pages.yml" ]; then
  echo "Workflow: gh-pages.yml present"
else
  echo "Workflow: gh-pages.yml missing"
fi

echo
# Final verdict
if [ "$MISSING" -eq 0 ]; then
  echo "RESULT: repo looks complete for a local test and GitHub Pages deploy."
  echo "Next steps: start API (api/app.py) and serve webapp/static on port 8000."
else
  echo "RESULT: repo has missing items. Fix the MISSING entries above before deploying."
fi

echo
echo "Quick commands to run tomorrow from this machine:"
echo "  # start API (example)"
echo "  cd $ROOT/api && FLASK_APP=app.py flask run --host=127.0.0.1 --port=9090"
echo "  # serve static UI"
echo "  cd $ROOT/webapp/static && python3 -m http.server 8000 --bind 127.0.0.1"
echo
