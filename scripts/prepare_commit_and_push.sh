#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

mkdir -p .logs .backup docs/data docs/assets/js agents scripts

# Backup current critical files
ts=$(date +%s)
mkdir -p .backup/$ts
cp -v server/wallet_api.py agents/orchestrator.py agents/economist.py docs/index.html .backup/$ts/ 2>/dev/null || true

# Write server/wallet_api.py
cat > server/wallet_api.py <<'PY'
#!/usr/bin/env python3
import datetime
import io, json, os

from flask import Flask, request, jsonify, abort

ROOT = os.path.join(os.path.dirname(__file__), "..")
DATA_FILE = os.path.join(ROOT, "docs", "data", "energy_wallets.json")

app = Flask("ghosttrack_wallet_api")

def load_data():
    with io.open(DATA_FILE, "r", encoding="utf-8") as f:
        return json.load(f)

def save_data(data):
    with io.open(DATA_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

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

if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5001, debug=False)
PY

# Write agents/economist.py
cat > agents/economist.py <<'PY'
#!/usr/bin/env python3
import time, requests, os, json, datetime

API = "http://127.0.0.1:5001"
CHECK_INTERVAL = 5
POOL_ID = "pool-community"

def utc():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()

def load_wallets():
    r = requests.get(f"{API}/wallets", timeout=5)
    r.raise_for_status()
    return r.json().get("wallets", [])

def compute_donation_weight(impulsi):
    return max(0, impulsi // 10)

def propose_donations(wallets):
    proposals = []
    for w in wallets:
        if w.get("id") == POOL_ID:
            continue
        weight = compute_donation_weight(w.get("impulsi", 0))
        if weight > 0:
            proposals.append({
                "from": w.get("id"),
                "available_impulsi": w.get("impulsi", 0),
                "donation_weight": weight,
                "suggested_impulsi": weight * 10
            })
    return proposals

def atomic_write(path, data):
    tmp = path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
    os.replace(tmp, path)

def main_loop():
    print(f"[{utc()}] Economist avviato")
    out_path = os.path.join(os.path.dirname(__file__), "..", "docs", "data", "donation_proposals.json")
    while True:
        try:
            wallets = load_wallets()
            proposals = propose_donations(wallets)
            payload = {"ts": utc(), "proposals": proposals}
            atomic_write(out_path, payload)
            print(f"[{utc()}] Ciclo OK — {len(proposals)} proposte generate")
            time.sleep(CHECK_INTERVAL)
        except Exception as e:
            print(f"[{utc()}] Errore Economist: {e}")
            time.sleep(3)

if __name__ == "__main__":
    main_loop()
PY

# Write approval panel JS
cat > docs/assets/js/approval_panel.js <<'JS'
const ApprovalPanel = {
  base: "http://127.0.0.1:5001",
  proposalsPath: "/data/donation_proposals.json",
  async loadProposals() {
    try {
      const r = await fetch(this.proposalsPath + "?_=" + Date.now());
      if (!r.ok) return null;
      return r.json();
    } catch (e) { return null; }
  },
  async render(containerId) {
    const el = document.getElementById(containerId);
    if (!el) return;
    const data = await this.loadProposals();
    if (!data || !data.proposals || data.proposals.length === 0) {
      el.innerHTML = "<p>Nessuna proposta di donazione al momento.</p>";
      return;
    }
    el.innerHTML = data.proposals.map(p => `
      <div class="proposal">
        <strong>${p.from}</strong> — impulsi: ${p.available_impulsi} — suggeriti: ${p.suggested_impulsi}
        <button data-from="${p.from}" data-amount="${p.suggested_impulsi}" class="approve-btn">Approva</button>
      </div>
    `).join("");
    el.querySelectorAll(".approve-btn").forEach(btn => {
      btn.addEventListener("click", async e => {
        const from = e.target.dataset.from;
        const amount = parseInt(e.target.dataset.amount,10);
        await fetch(`${this.base}/wallets/${from}/transact`, {
          method: "POST",
          headers: {"Content-Type":"application/json"},
          body: JSON.stringify({ amount: -amount, type: "donate", meta: { to: "pool-community" } })
        });
        await fetch(`${this.base}/wallets/pool-community/transact`, {
          method: "POST",
          headers: {"Content-Type":"application/json"},
          body: JSON.stringify({ amount: amount, type: "receive", meta: { from } })
        });
        this.render(containerId);
      });
    });
  }
};
JS

# Append approval panel to docs/index.html if missing
if ! grep -q "approval-panel" docs/index.html 2>/dev/null; then
  cat >> docs/index.html <<'HTML'
<!-- Approval panel -->
<div id="approval-panel"></div>
<script src="assets/js/approval_panel.js"></script>
<script>document.addEventListener("DOMContentLoaded", ()=>ApprovalPanel.render("approval-panel"))</script>
<!-- End approval panel -->
HTML
fi

# Create sample wallets file if missing
if [ ! -f docs/data/energy_wallets.json ]; then
  cat > docs/data/energy_wallets.json <<'JSON'
{
  "wallets": [
    {"id":"pool-community","impulsi":0},
    {"id":"user-roberto","impulsi":128},
    {"id":"user-luca","impulsi":64},
    {"id":"user-anna","impulsi":200},
    {"id":"user-maria","impulsi":20}
  ]
}
JSON
fi

# Create final deploy script
cat > scripts/final_deploy_full.sh <<'SH2'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
mkdir -p .logs
# stop old services
for f in .logs/*.pid; do [ -f "$f" ] && kill $(cat "$f") 2>/dev/null || true; done
sleep 1
# start static server
cd docs
nohup python3 -m http.server 8080 > ../.logs/local_server.log 2>&1 &
echo $! > ../.logs/local_server.pid
cd "$ROOT"
# start wallet_api
nohup python3 server/wallet_api.py > .logs/wallet_api.log 2>&1 &
echo $! > .logs/wallet_api.pid
sleep 1
# start orchestrator if exists
if [ -f agents/orchestrator.py ]; then
  nohup python3 agents/orchestrator.py > .logs/orchestrator.log 2>&1 &
  echo $! > .logs/orchestrator.pid
fi
sleep 1
# start economist
nohup python3 agents/economist.py > .logs/economist.log 2>&1 &
echo $! > .logs/economist.pid
sleep 2
echo "Services started. Check .logs/*.log"
SH2
chmod +x scripts/final_deploy_full.sh

# Make executables
chmod +x server/wallet_api.py agents/economist.py

# Run final deploy script
./scripts/final_deploy_full.sh

# Git commit and push
git checkout -B feature/initial-mvp
git add server/wallet_api.py agents/economist.py docs/assets/js/approval_panel.js docs/index.html docs/data/energy_wallets.json scripts/final_deploy_full.sh scripts/prepare_commit_and_push.sh || true
git commit -m "chore: add wallet_api, economist, approval panel, deploy scripts, sample data" || true
echo "Attempting git push (may require credentials)..."
git push -u origin feature/initial-mvp || echo "git push failed; configure remote/credentials"

echo "Done. Opening nano for quick review of docs/index.html"
nano docs/index.html
