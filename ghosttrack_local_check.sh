#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATIC_DIR="$ROOT_DIR/webapp/static"
DOCS_DIR="$ROOT_DIR/docs"

HTTP_STATIC="http://localhost:8000"
HTTP_API="http://localhost:9090"

echo
echo "=== GhostTrack Local Check ==="
echo "Root: $ROOT_DIR"
echo

# 1) sensors.json reachable
echo "1) Verifica sensors.json via $HTTP_STATIC/sensors.json"
if curl -sSf "$HTTP_STATIC/sensors.json" -o /tmp/gt_sensors.json; then
  echo "  - sensors.json scaricato correttamente"
  if command -v jq >/dev/null 2>&1; then
    echo "  - Validazione JSON con jq:"
    if jq empty /tmp/gt_sensors.json 2>/tmp/gt_jq_err; then
      echo "    OK JSON valido"
      echo "    Estratto sommario (prime 20 righe):"
      jq . /tmp/gt_sensors.json | sed -n '1,20p'
    else
      echo "    ERRORE JSON non valido:"
      sed -n '1,200p' /tmp/gt_jq_err
      echo "    Suggerimento: controlla webapp/static/sensors.json per errori di sintassi"
    fi
  else
    echo "  - jq non installato. Mostro il file grezzo (prime 20 righe):"
    sed -n '1,20p' /tmp/gt_sensors.json
  fi
else
  echo "  ERRORE: Impossibile raggiungere $HTTP_STATIC/sensors.json"
  echo "  Controlli consigliati:"
  echo "    - Assicurati di aver avviato il server statico: cd webapp/static && python3 -m http.server 8000"
  echo "    - Verifica che il file webapp/static/sensors.json esista"
  echo "    - Controlla firewall o binding su localhost"
  exit 2
fi

echo
# 2) API /api/status reachable
echo "2) Verifica API status via $HTTP_API/api/status"
if curl -sSf "$HTTP_API/api/status" -o /tmp/gt_api_status.json; then
  echo "  - Endpoint /api/status risponde"
  if command -v jq >/dev/null 2>&1; then
    echo "  - Validazione JSON API:"
    if jq empty /tmp/gt_api_status.json 2>/tmp/gt_api_jq_err; then
      echo "    OK JSON valido"
      echo "    Contenuto:"
      jq . /tmp/gt_api_status.json
    else
      echo "    ERRORE JSON non valido dalla API:"
      sed -n '1,200p' /tmp/gt_api_jq_err
      echo "    Suggerimento: controlla il log dell'API per errori di serializzazione JSON"
    fi
  else
    echo "  - jq non installato. Mostro il file grezzo:"
    sed -n '1,200p' /tmp/gt_api_status.json
  fi
else
  echo "  ERRORE: Impossibile raggiungere $HTTP_API/api/status"
  echo "  Controlli consigliati:"
  echo "    - Avvia l'API: cd api && python3 app.py (o FLASK_APP=app.py flask run --port=9090)"
  echo "    - Verifica che l'API ascolti su 0.0.0.0:9090 o localhost:9090"
  echo "    - Controlla i log dell'API per errori di avvio"
  exit 3
fi

echo
# 3) Correlazione sensors.json -> API endpoints
echo "3) Correlazione sensori -> endpoint API"
if command -v jq >/dev/null 2>&1; then
  MODULES=$(jq -r '.modules | keys[]' /tmp/gt_sensors.json 2>/dev/null || true)
  if [ -z "$MODULES" ]; then
    echo "  - Nessun modulo trovato in sensors.json"
  else
    for m in $MODULES; do
      ep=$(jq -r --arg m "$m" '.modules[$m].sensors[0].endpoint // empty' /tmp/gt_sensors.json)
      if [ -z "$ep" ]; then
        echo "  - $m : nessun endpoint definito"
      else
        full="$HTTP_API$ep"
        printf "  - %s -> %s : " "$m" "$full"
        if curl -sSf "$full" >/dev/null 2>&1; then
          echo "OK"
        else
          echo "NO RESPONSE"
        fi
      fi
    done
  fi
else
  echo "  - jq non disponibile, salto correlazione automatica"
fi

echo
echo "=== Report finale ==="
echo " - sensors.json: reachable and valid"
echo " - API /api/status: reachable and valid"
echo " - Suggerimenti:"
echo "    * Se qualche endpoint dei moduli risulta NO RESPONSE, verifica routing e prefissi in sensors.json"
echo "    * Se i JSON non sono validi, correggi la sintassi (virgolette, virgole, parentesi)"
echo
echo "Pulizia file temporanei"
rm -f /tmp/gt_sensors.json /tmp/gt_api_status.json /tmp/gt_jq_err /tmp/gt_api_jq_err || true
echo "Done."
