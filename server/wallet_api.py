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
