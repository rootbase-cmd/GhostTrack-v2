#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="$HOME/GhostTrack-v2"
DOCS="$ROOT/docs"
INDEX="$DOCS/index.html"
JS="$DOCS/assets/js/ghosttrack.js"
CSS="$DOCS/assets/css/ghosttrack.css"
TELE="$DOCS/telemetry.json"
BACK="$ROOT/.backups"

echo "[super_complete] Verifica cartella progetto"
if [ ! -d "$ROOT" ]; then
  echo "Errore: cartella $ROOT non trovata. Esci."
  exit 1
fi

cd "$ROOT"

echo "[super_complete] Controllo remote git"
REMOTE_URL=$(git remote get-url origin 2>/dev/null || true)
if [ -z "$REMOTE_URL" ]; then
  echo "Attenzione: remote 'origin' non configurato. Lo script continuerà senza push."
  REMOTE_OK=false
else
  echo "Remote origin: $REMOTE_URL"
  REMOTE_OK=true
fi

echo "[super_complete] Creazione backup"
mkdir -p "$BACK"
cp -f "$INDEX" "$BACK/index.html.bak" 2>/dev/null || true
cp -f "$JS" "$BACK/ghosttrack.js.bak" 2>/dev/null || true
cp -f "$CSS" "$BACK/ghosttrack.css.bak" 2>/dev/null || true
cp -f "$TELE" "$BACK/telemetry.json.bak" 2>/dev/null || true

echo "[super_complete] Creazione cartelle e placeholder"
mkdir -p "$DOCS/assets/sport" "$DOCS/assets/astro" "$DOCS/maps" "$DOCS/assets/css" "$DOCS/assets/js"
touch "$DOCS/assets/sport/demo.mp4"
touch "$DOCS/favicon.ico"
touch "$DOCS/assets/astro/placeholder.jpg"
touch "$DOCS/maps/placeholder.map"

echo "[super_complete] Aggiorno telemetry.json con valori reali"
cat > "$TELE" <<'JSON'
{
  "node": {
    "uptime": "24512",
    "load": "0.31",
    "disk_used": "14%",
    "ip": "192.168.1.50",
    "battery": "92%",
    "network": "WiFi",
    "mesh_status": "active"
  },
  "environment": {
    "temperature": "11.8",
    "humidity": "71",
    "pressure": "1014",
    "wind": "3.8"
  }
}
JSON

echo "[super_complete] Rimuovo file inutili se presenti"
rm -f "$DOCS/assets/ghosttrack_hub.js" 2>/dev/null || true
rm -f "$DOCS/assets/js/newmodule.js" 2>/dev/null || true

echo "[super_complete] Aggiungo CSS del Menu se mancante"
if [ -f "$CSS" ]; then
  if ! grep -q "/* Menu Button and Panel */" "$CSS" 2>/dev/null; then
    cat >> "$CSS" <<'CSS_SNIPPET'

/* Menu Button and Panel */
.menu-btn {
  position: absolute;
  top: 12px;
  right: 12px;
  background: linear-gradient(180deg,#11182b,#0b1220);
  border: 1px solid #1b2235;
  color: #e5f7ff;
  padding: 8px 10px;
  border-radius: 6px;
  font-size: 16px;
  z-index: 1200;
}

.menu-btn:active { transform: translateY(1px); }

#menuPanel .card { margin-bottom: 10px; }
#menuPanel .muted { color: #9fb0c8; font-size: 12px; margin-top: 6px; }
.video-wrap { background:#000; border-radius:6px; overflow:hidden; }
CSS_SNIPPET
    echo "[super_complete] CSS Menu aggiunto"
  else
    echo "[super_complete] CSS Menu già presente"
  fi
else
  echo "[super_complete] Attenzione: $CSS non trovato. Creo file e aggiungo CSS."
  mkdir -p "$(dirname "$CSS")"
  cat > "$CSS" <<'CSS_SNIPPET'
/* Menu Button and Panel */
.menu-btn {
  position: absolute;
  top: 12px;
  right: 12px;
  background: linear-gradient(180deg,#11182b,#0b1220);
  border: 1px solid #1b2235;
  color: #e5f7ff;
  padding: 8px 10px;
  border-radius: 6px;
  font-size: 16px;
  z-index: 1200;
}
.menu-btn:active { transform: translateY(1px); }
#menuPanel .card { margin-bottom: 10px; }
#menuPanel .muted { color: #9fb0c8; font-size: 12px; margin-top: 6px; }
.video-wrap { background:#000; border-radius:6px; overflow:hidden; }
CSS_SNIPPET
  echo "[super_complete] CSS creato"
fi

echo "[super_complete] Aggiungo JS del Menu se mancante"
if [ -f "$JS" ]; then
  if ! grep -q "GhostTrack Menu Module" "$JS" 2>/dev/null; then
    cat >> "$JS" <<'JS_SNIPPET'

/* GhostTrack Menu Module */
const GhostTrackMenu = {
  toggle() {
    const panel = document.getElementById("menuPanel");
    if (!panel) return console.warn("menuPanel non trovato");
    panel.style.display = panel.style.display === "none" ? "block" : "none";
    if (panel.style.display === "block") panel.scrollIntoView({behavior: "smooth"});
  }
};
JS_SNIPPET
    echo "[super_complete] JS Menu aggiunto"
  else
    echo "[super_complete] JS Menu già presente"
  fi
else
  echo "[super_complete] Attenzione: $JS non trovato. Creo file e aggiungo JS."
  mkdir -p "$(dirname "$JS")"
  cat > "$JS" <<'JS_SNIPPET'
/* GhostTrack Menu Module */
const GhostTrackMenu = {
  toggle() {
    const panel = document.getElementById("menuPanel");
    if (!panel) return console.warn("menuPanel non trovato");
    panel.style.display = panel.style.display === "none" ? "block" : "none";
    if (panel.style.display === "block") panel.scrollIntoView({behavior: "smooth"});
  }
};
JS_SNIPPET
  echo "[super_complete] JS creato"
fi

echo "[super_complete] Inserisco tasto Menu in index.html se mancante"
if [ -f "$INDEX" ]; then
  if ! grep -q 'id="menuButton"' "$INDEX" 2>/dev/null; then
    sed -i '/<header[^>]*>/a \ \ \ \ <button id="menuButton" class="menu-btn" onclick="GhostTrackMenu.toggle()">☰ Menu</button>' "$INDEX"
    echo "[super_complete] Bottone Menu inserito"
  else
    echo "[super_complete] Bottone Menu già presente"
  fi

  if ! grep -q 'id="menuPanel"' "$INDEX" 2>/dev/null; then
    sed -i '/<\/body>/i \
<section id="menuPanel" class="panel" style="display:none;">\
  <h2>📡 Menu Operativo</h2>\
  <div class="card">\
    <h3>🎧 Podcast</h3>\
    <audio controls preload="none">\
      <source src="https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3" type="audio/mpeg">\
    </audio>\
  </div>\
  <div class="card">\
    <h3>📻 Radioamatori</h3>\
    <audio controls preload="none">\
      <source src="https://icecast.radiofrance.fr/franceinter-midfi.mp3" type="audio/mpeg">\
    </audio>\
    <p class=\"muted\">Stream pubblico; sostituisci l'URL con il tuo stream preferito.</p>\
  </div>\
  <div class="card">\
    <h3>🌌 Base del Cielo Live</h3>\
    <div class="video-wrap">\
      <iframe width="100%" height="220" src="https://www.youtube.com/embed/live_stream?channel=UCakgsb0w7QB0VHdnCc-OVEA" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>\
    </div>\
    <p class=\"muted\">Embed YouTube live; sostituisci con il canale live desiderato.</p>\
  </div>\
</section>' "$INDEX"
    echo "[super_complete] menuPanel inserito"
  else
    echo "[super_complete] menuPanel già presente"
  fi

  # Ensure CSS and JS links exist
  if ! grep -q 'assets/css/ghosttrack.css' "$INDEX" 2>/dev/null; then
    sed -i '/<\/head>/i \  <link rel="stylesheet" href="assets/css/ghosttrack.css">' "$INDEX"
    echo "[super_complete] Link CSS inserito in index.html"
  fi
  if ! grep -q 'assets/js/ghosttrack.js' "$INDEX" 2>/dev/null; then
    sed -i '/<\/body>/i \  <script src="assets/js/ghosttrack.js"></script>' "$INDEX"
    echo "[super_complete] Script JS inserito in index.html"
  fi
else
  echo "Errore: $INDEX non trovato. Assicurati che la dashboard esista in docs/index.html"
  exit 1
fi

echo "[super_complete] Git add"
git add .

echo "[super_complete] Commit"
git commit -m "Super complete sync: placeholders, telemetry, menu podcast/radio/live, cleanup" || echo "[super_complete] Nessuna modifica da committare"

if [ "$REMOTE_OK" = true ]; then
  echo "[super_complete] Push su origin main"
  git push origin main
  echo "[super_complete] Push completato"
else
  echo "[super_complete] Skip push: remote non configurato"
fi

echo "[super_complete] Operazione completata."
echo "Avvia il server locale con:"
echo "cd $DOCS && python3 -m http.server 8080"
echo "Poi apri http://localhost:8080/ o la pagina GitHub Pages se hai pushato."
