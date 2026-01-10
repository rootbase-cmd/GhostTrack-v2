#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

LOG=".logs/full_integration.log"
mkdir -p .logs .backup docs/data docs/assets/js agents scripts

echo "=== START FULL INTEGRATION $(date -u) ===" | tee -a "$LOG"

# backup
ts=$(date +%s)
mkdir -p .backup/$ts
cp -v server/wallet_api.py agents/economist.py docs/index.html docs/assets/js/approval_panel.js docs/assets/js || true

# 1) Patch server/wallet_api.py: add /status endpoint (reads donation_proposals.json and reports process status)
cat > server/wallet_api.py <<'PY'
#!/usr/bin/env python3
import datetime, io, json, os
from flask import Flask, request, jsonify, abort

ROOT = os.path.join(os.path.dirname(__file__), "..")
DATA_FILE = os.path.join(ROOT, "docs", "data", "energy_wallets.json")
PROPOSALS_FILE = os.path.join(ROOT, "docs", "data", "donation_proposals.json")
app = Flask("ghosttrack_wallet_api")

def load_data():
    with io.open(DATA_FILE, "r", encoding="utf-8") as f:
        return json.load(f)

def save_data(data):
    with io.open(DATA_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

def load_proposals():
    try:
        with io.open(PROPOSALS_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return {"ts": None, "proposals": []}

@app.route("/wallets", methods=["GET"])
def list_wallets():
    data = load_data()
    return jsonify(data)

@app.route("/wallets/<wallet_id>", methods=["GET"])
def get_wallet(wallet_id):
    data = load_data()
    for w in data.get("wallets", []):
        if w["id"] == wallet_id:
            return jsonify(w)
    abort(404)

@app.route("/wallets/<wallet_id>/transact", methods=["POST"])
def transact(wallet_id):
    payload = request.get_json(force=True)
    if not payload or "amount" not in payload or "type" not in payload:
        abort(400)
    data = load_data()
    for w in data.get("wallets", []):
        if w["id"] == wallet_id:
            w["impulsi"] = max(0, w.get("impulsi", 0) + int(payload["amount"]))
            entry = {
                "ts": datetime.datetime.now(datetime.timezone.utc).isoformat(),
                "type": payload["type"],
                "amount": int(payload["amount"]),
                "meta": payload.get("meta", {})
            }
            w.setdefault("history", []).append(entry)
            save_data(data)
            return jsonify({"status": "ok", "wallet": w})
    abort(404)

@app.route("/status", methods=["GET"])
def status():
    # basic health: wallet_api up, proposals ts, economist last cycle inferred from file mtime
    proposals = load_proposals()
    proposals_ts = proposals.get("ts")
    try:
        mtime = os.path.getmtime(PROPOSALS_FILE)
        economist_last = datetime.datetime.fromtimestamp(mtime, datetime.timezone.utc).isoformat()
    except Exception:
        economist_last = None
    # simple process checks: not exhaustive, just report presence of files/pids
    pids = {}
    for name in ["local_server","wallet_api","orchestrator","economist"]:
        pidfile = os.path.join(ROOT, ".logs", f"{name}.pid")
        if os.path.exists(pidfile):
            try:
                with open(pidfile,"r") as f:
                    p = int(f.read().strip())
                pids[name] = {"pid": p, "alive": os.path.exists(f"/proc/{p}")}
            except Exception:
                pids[name] = {"pid": None, "alive": False}
        else:
            pids[name] = {"pid": None, "alive": False}
    return jsonify({
        "service": "wallet_api",
        "ok": True,
        "proposals_ts": proposals_ts,
        "economist_last_write": economist_last,
        "pids": pids
    })

if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5001, debug=False)
PY

# 2) Badge + audit UI: docs/assets/js/status_badge.js and docs/assets/js/audit_panel.js
cat > docs/assets/js/status_badge.js <<'JS'
const StatusBadge = {
  statusPath: "/status",
  async fetchStatus() {
    try {
      const r = await fetch(this.statusPath + "?_=" + Date.now());
      if (!r.ok) return null;
      return r.json();
    } catch (e) { return null; }
  },
  async render(containerId) {
    const el = document.getElementById(containerId);
    if (!el) return;
    const s = await this.fetchStatus();
    if (!s) {
      el.innerHTML = '<span class="badge badge-error">offline</span>';
      return;
    }
    const ok = s.ok ? 'online' : 'degraded';
    el.innerHTML = `<span class="badge badge-${ok}">API ${ok}</span>
      <small>proposals: ${s.proposals_ts || "n/a"}</small>`;
  }
};
JS

cat > docs/assets/js/audit_panel.js <<'JS'
const AuditPanel = {
  proposalsPath: "/data/donation_proposals.json",
  auditLogPath: "/data/audit_log.json",
  async loadProposals() {
    try {
      const r = await fetch(this.proposalsPath + "?_=" + Date.now());
      if (!r.ok) return null;
      return r.json();
    } catch (e) { return null; }
  },
  async loadAudit() {
    try {
      const r = await fetch(this.auditLogPath + "?_=" + Date.now());
      if (!r.ok) return {entries:[]};
      return r.json();
    } catch (e) { return {entries:[]}; }
  },
  async render(containerId) {
    const el = document.getElementById(containerId);
    if (!el) return;
    const proposals = await this.loadProposals();
    const audit = await this.loadAudit();
    let html = '<h3>Proposte</h3>';
    if (!proposals || !proposals.proposals || proposals.proposals.length===0) {
      html += "<p>Nessuna proposta.</p>";
    } else {
      html += proposals.proposals.map(p=>`<div><strong>${p.from}</strong> — ${p.suggested_impulsi} impulsi <button data-from="${p.from}" data-amount="${p.suggested_impulsi}" class="approve-btn">Approva</button></div>`).join("");
    }
    html += "<h3>Audit</h3>";
    html += (audit.entries && audit.entries.length>0) ? audit.entries.map(e=>`<div>${e.ts} — ${e.actor} — ${e.action} — ${e.amount}</div>`).join("") : "<p>Vuoto</p>";
    el.innerHTML = html;
    el.querySelectorAll(".approve-btn").forEach(btn=>{
      btn.addEventListener("click", async e=>{
        const from = e.target.dataset.from;
        const amount = parseInt(e.target.dataset.amount,10);
        await fetch(`/wallets/${from}/transact`, {
          method:"POST",
          headers:{"Content-Type":"application/json"},
          body: JSON.stringify({amount:-amount,type:"donate",meta:{to:"pool-community"}})
        });
        await fetch(`/wallets/pool-community/transact`, {
          method:"POST",
          headers:{"Content-Type":"application/json"},
          body: JSON.stringify({amount:amount,type:"receive",meta:{from}})
        });
        // append audit locally by POST to a simple file-updater endpoint (not available here),
        // fallback: trigger re-render and rely on server-side audit if implemented.
        this.render(containerId);
      });
    });
  }
};
JS

# 3) Add audit_log.json if missing
if [ ! -f docs/data/audit_log.json ]; then
  cat > docs/data/audit_log.json <<'JSON'
{"entries":[]}
JSON
fi

# 4) Append badge and audit panel to index.html if missing
if ! grep -q "status-badge" docs/index.html 2>/dev/null; then
  cat >> docs/index.html <<'HTML'
<!-- Status badge -->
<div id="status-badge" style="position:fixed;right:12px;top:12px;z-index:9999"></div>
<script src="assets/js/status_badge.js"></script>
<script>document.addEventListener("DOMContentLoaded", ()=>StatusBadge.render("status-badge"))</script>
<!-- End status badge -->
HTML
fi

if ! grep -q "audit-panel" docs/index.html 2>/dev/null; then
  cat >> docs/index.html <<'HTML'
<!-- Audit panel -->
<div id="audit-panel" style="margin-top:20px"></div>
<script src="assets/js/audit_panel.js"></script>
<script>document.addEventListener("DOMContentLoaded", ()=>AuditPanel.render("audit-panel"))</script>
<!-- End audit panel -->
HTML
fi

# 5) Simple notifier script (Telegram or Matrix) - configure via env vars TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID or MATRIX_WEBHOOK
cat > scripts/notifier.sh <<'SHN'
#!/usr/bin/env bash
# Usage: TELEGRAM_BOT_TOKEN=xxx TELEGRAM_CHAT_ID=yyy ./scripts/notifier.sh "Message text"
MSG="${1:-no message}"
if [ -n "${TELEGRAM_BOT_TOKEN:-}" ] && [ -n "${TELEGRAM_CHAT_ID:-}" ]; then
  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d chat_id="${TELEGRAM_CHAT_ID}" -d text="$MSG" >/dev/null 2>&1 || true
fi
if [ -n "${MATRIX_WEBHOOK:-}" ]; then
  curl -s -X POST "${MATRIX_WEBHOOK}" -H "Content-Type: application/json" -d "{\"text\":\"$MSG\"}" >/dev/null 2>&1 || true
fi
echo "notified"
SHN
chmod +x scripts/notifier.sh

# 6) Restart services (static, wallet_api, orchestrator, economist)
echo "[RESTART] stopping old pids" | tee -a "$LOG"
for f in .logs/local_server.pid .logs/wallet_api.pid .logs/orchestrator.pid .logs/economist.pid; do
  if [ -f "$f" ]; then
    pid=$(cat "$f" 2>/dev/null || true)
    [ -n "$pid" ] && kill "$pid" 2>/dev/null || true
  fi
done
sleep 1

echo "[RESTART] starting static server" | tee -a "$LOG"
cd docs
nohup python3 -m http.server 8080 > ../.logs/local_server.log 2>&1 &
echo $! > ../.logs/local_server.pid
cd "$ROOT"
sleep 1

echo "[RESTART] starting wallet_api" | tee -a "$LOG"
nohup python3 server/wallet_api.py > .logs/wallet_api.log 2>&1 &
echo $! > .logs/wallet_api.pid
sleep 1

if [ -f agents/orchestrator.py ]; then
  echo "[RESTART] starting orchestrator" | tee -a "$LOG"
  nohup python3 agents/orchestrator.py > .logs/orchestrator.log 2>&1 &
  echo $! > .logs/orchestrator.pid
  sleep 1
fi

echo "[RESTART] starting economist" | tee -a "$LOG"
nohup python3 agents/economist.py > .logs/economist.log 2>&1 &
echo $! > .logs/economist.pid
sleep 2

# 7) Git commit & push
echo "[GIT] commit and push" | tee -a "$LOG"
git checkout -B feature/initial-mvp
git add server/wallet_api.py agents/economist.py docs/assets/js/status_badge.js docs/assets/js/audit_panel.js docs/assets/js/approval_panel.js docs/index.html docs/data/audit_log.json scripts/notifier.sh scripts/final_deploy_full.sh scripts/add_status_audit_notify_and_deploy.sh || true
git commit -m "feat: add /status endpoint, status badge, audit panel, notifier and deploy scripts" || true
git push -u origin feature/initial-mvp || echo "git push failed; configure remote/credentials" | tee -a "$LOG"

# 8) Quick verification
echo "[VERIFY] processes" | tee -a "$LOG"
ps aux | grep -E "wallet_api|http.server|orchestrator|economist" | grep -v grep | tee -a "$LOG"
echo "[VERIFY] wallet_api log tail" | tee -a "$LOG"
tail -n 80 .logs/wallet_api.log | tee -a "$LOG"
echo "[VERIFY] economist log tail" | tee -a "$LOG"
tail -n 80 .logs/economist.log | tee -a "$LOG"
echo "=== END $(date -u) ===" | tee -a "$LOG"

echo "Integration complete. If you want notifications, set TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID and run:"
echo "  TELEGRAM_BOT_TOKEN=xxx TELEGRAM_CHAT_ID=yyy ./scripts/notifier.sh \"GhostTrack: deploy complete\""

