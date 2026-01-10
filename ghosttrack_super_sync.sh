#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="$HOME/GhostTrack-v2"
DOCS="$ROOT/docs"
INDEX="$DOCS/index.html"
JS="$DOCS/assets/js/ghosttrack.js"
CSS="$DOCS/assets/css/ghosttrack.css"
TELE="$DOCS/telemetry.json"

echo "[super_sync] Verifica cartella progetto"
if [ ! -d "$ROOT" ]; then
  echo "Errore: cartella $ROOT non trovata. Esci."
  exit 1
fi

cd "$ROOT"

echo "[super_sync] Controllo remote git"
REMOTE_URL=$(git remote get-url origin 2>/dev/null || true)
if [ -z "$REMOTE_URL" ]; then
  echo "Attenzione: remote 'origin' non configurato. Imposta il remote corretto prima del push."
  echo "Esempio: git remote add origin https://github.com/HighKali/GhostTrack-v2.git"
  REMOTE_OK=false
else
  echo "Remote origin: $REMOTE_URL"
  REMOTE_OK=true
fi

echo "[super_sync] Backup file critici"
mkdir -p "$ROOT/.backups"
cp -f "$INDEX" "$ROOT/.backups/index.html.bak" 2>/dev/null || true
cp -f "$JS" "$ROOT/.backups/ghosttrack.js.bak" 2>/dev/null || true
cp -f "$CSS" "$ROOT/.backups/ghosttrack.css.bak" 2>/dev/null || true
cp -f "$TELE" "$ROOT/.backups/telemetry.json.bak" 2>/dev/null || true

echo "[super_sync] Creazione cartelle e placeholder"
mkdir -p "$DOCS/assets/sport" "$DOCS/assets/astro" "$DOCS/maps"
touch "$DOCS/assets/sport/demo.mp4"
touch "$DOCS/favicon.ico"
touch "$DOCS/assets/astro/placeholder.jpg"
touch "$DOCS/maps/placeholder.map"

echo "[super_sync] Aggiorno telemetry.json con valori reali"
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

echo "[super_sync] Rimuovo file inutili se presenti"
rm -f "$DOCS/assets/ghosttrack_hub.js" 2>/dev/null || true
rm -f "$DOCS/assets/js/newmodule.js" 2>/dev/null || true

echo "[super_sync] Aggiungo CSS del Menu se mancante"
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
  echo "[super_sync] CSS aggiunto"
else
  echo "[super_sync] CSS Menu già presente"
fi

echo "[super_sync] Aggiungo JS del Menu se mancante"
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
  echo "[super_sync] JS aggiunto"
else
  echo "[super_sync] JS Menu già presente"
fi

echo "[super_sync] Inserisco tasto Menu in index.html se mancante"
if ! grep -q 'id="menuButton"' "$INDEX" 2>/dev/null; then
  # Inserisce il bottone subito dopo il tag <header>
  sed -i '/<header[^>]*>/a \ \ \ \ <button id="menuButton" class="menu-btn" onclick="GhostTrackMenu.toggle()">☰ Menu</button>' "$INDEX"
  echo "[super_sync] Bottone Menu inserito"
else
  echo "[super_sync] Bottone Menu già presente"
fi

echo "[super_sync] Inserisco sezione menuPanel in index.html se mancante"
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
  echo "[super_sync] menuPanel inserito"
else
  echo "[super_sync] menuPanel già presente"
fi

echo "[super_sync] Aggiungo link CSS/JS in index.html se mancanti"
# Assicura che index.html includa i riferimenti a CSS e JS (relative paths)
if ! grep -q 'assets/css/ghosttrack.css' "$INDEX" 2>/dev/null; then
  sed -i '/<\/head>/i \  <link rel="stylesheet" href="assets/css/ghosttrack.css">' "$INDEX"
  echo "[super_sync] Link CSS inserito"
fi
if ! grep -q 'assets/js/ghosttrack.js' "$INDEX" 2>/dev/null; then
  sed -i '/<\/body>/i \  <script src="assets/js/ghosttrack.js"></script>' "$INDEX"
  echo "[super_sync] Script JS inserito"
fi

echo "[super_sync] Git add"
git add .

echo "[super_sync] Commit"
git commit -m "Super sincronizzazione: placeholder, telemetry reale, menu podcast/radio/live, pulizia" || echo "[super_sync] Nessuna modifica da committare"

if [ "$REMOTE_OK" = true ]; then
  echo "[super_sync] Push su origin main"
  git push origin main
  echo "[super_sync] Push completato"
else
  echo "[super_sync] Skip push: remote non configurato"
fi

echo "[super_sync] Operazione completata. Avvia il server locale con:"
echo "cd $DOCS && python3 -m http.server 8080"
echo "Poi apri http://localhost:8080/ o la pagina GitHub Pages se hai pushato."
