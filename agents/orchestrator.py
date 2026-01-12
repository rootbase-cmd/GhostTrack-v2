#!/usr/bin/env python3
import time, requests, os, json

API = "http://127.0.0.1:5001"
CHECK_INTERVAL = 15  # secondi

def list_wallets():
    r = requests.get(f"{API}/wallets")
    r.raise_for_status()
    return r.json()["wallets"]

def suggest_rebalance(wallets):
    suggestions = []
    for w in wallets:
        if w.get("impulsi",0) < 20 and w["id"] != "pool-community":
            suggestions.append({
                "wallet": w["id"],
                "action": "request_donation",
                "reason": "basso saldo",
                "suggested_amount": 20 - w["impulsi"]
            })
    return suggestions

def main_loop():
    print("Orchestrator avviato")
    while True:
        try:
            wallets = list_wallets()
            suggestions = suggest_rebalance(wallets)
            if suggestions:
                print("Suggerimenti:", json.dumps(suggestions, indent=2))
                # non eseguire transazioni automatiche senza approvazione umana
            time.sleep(CHECK_INTERVAL)
        except Exception as e:
            print("Errore orchestrator:", e)
            time.sleep(5)

if __name__ == "__main__":
    main_loop()
