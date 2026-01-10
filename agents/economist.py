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
