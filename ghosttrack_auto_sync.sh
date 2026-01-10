#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="$HOME/GhostTrack-v2"
DOCS="$ROOT/docs"
INDEX="$DOCS/index.html"
JS="$DOCS/assets/js/ghosttrack.js"
CSS="$DOCS/assets/css/ghosttrack.css"
TELE="$DOCS/telemetry.json"
BACK="$ROOT/.backups"

echo "[auto_sync] Backup"
mkdir -p "$BACK"
cp -f "$INDEX" "$BACK/index.html.bak" 2>/dev/null || true
cp -f "$JS" "$BACK/ghosttrack.js.bak" 2>/dev/null || true
cp -f "$CSS" "$BACK/ghosttrack.css.bak" 2>/dev/null || true

echo "[auto_sync] Placeholder"
mkdir -p "$DOCS/assets/sport" "$DOCS/assets/astro" "$DOCS/maps"
touch "$DOCS/assets/sport/demo.mp4"
touch "$DOCS/favicon.ico"
touch "$DOCS/assets/astro/placeholder.jpg"
touch "$DOCS/maps/placeholder.map"

echo "[auto_sync] Telemetry"
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

echo "[auto_sync] Dedup index.html"
TMP="$ROOT/.index.dedup.$$"
awk '!x[$0]++' "$INDEX" > "$TMP" && mv "$TMP" "$INDEX"

echo "[auto_sync] Inserimento menuPanel via Python"
python3 <<'PY'
import io, os

infile = "docs/index.html"
with io.open(infile, "r", encoding="utf-8") as f:
    html = f.read()

if 'id="menuPanel"' not in html:
    block = """
  <section id="menuPanel" class="panel" style="display:none;">
    <h2>📡 Menu Operativo</h2>

    <div class="card">
      <h3>🎧 Podcast</h3>
      <audio controls preload="none">
        <source src="https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3" type="audio/mpeg">
      </audio>
    </div>

    <div class="card">
      <h3>📻 Radioamatori</h3>
      <audio controls preload="none">
        <source src="https://icecast.radiofrance.fr/franceinter-midfi.mp3" type="audio/mpeg">
      </audio>
      <p class="muted">Stream pubblico; sostituisci l'URL con il tuo stream preferito.</p>
    </div>

    <div class="card">
      <h3>🌌 Base del Cielo Live</h3>
      <div class="video-wrap">
        <iframe width="100%" height="220"
                src="https://www.youtube.com/embed/live_stream?channel=UCakgsb0w7QB0VHdnCc-OVEA"
                frameborder="0" allowfullscreen></iframe>
      </div>
      <p class="muted">Embed YouTube live; sostituisci con il canale live desiderato.</p>
    </div>

  </section>
"""
    html = html.replace("</body>", block + "\n</body>")

    tmp = "docs/.index.panel.tmp"
    with io.open(tmp, "w", encoding="utf-8") as o:
        o.write(html)
    os.replace(tmp, infile)
PY

echo "[auto_sync] CSS/JS references"
grep -q 'assets/css/ghosttrack.css' "$INDEX" || sed -i '/<\/head>/i \  <link rel="stylesheet" href="assets/css/ghosttrack.css">' "$INDEX"
grep -q 'assets/js/ghosttrack.js' "$INDEX" || sed -i '/<\/body>/i \  <script src="assets/js/ghosttrack.js"></script>' "$INDEX"

echo "[auto_sync] CSS rules"
grep -q "Menu Button and Panel" "$CSS" || cat >> "$CSS" <<'CSS'
/* Menu Button and Panel */
.menu-btn {
  position: absolute;
  top: 12px;
  right: 12px;
  background: #11182b;
  border: 1px solid #1b2235;
  color: #e5f7ff;
  padding: 8px 10px;
  border-radius: 6px;
  font-size: 16px;
  z-index: 1200;
}
CSS

echo "[auto_sync] JS module"
grep -q "GhostTrack Menu Module" "$JS" || cat >> "$JS" <<'JS'
/* GhostTrack Menu Module */
const GhostTrackMenu = {
  toggle() {
    const panel = document.getElementById("menuPanel");
    if (!panel) return;
    panel.style.display = panel.style.display === "none" ? "block" : "none";
  }
};
JS

echo "[auto_sync] Git commit"
git add .
git commit -m "Auto sync: menuPanel, CSS/JS, telemetry, placeholders" || true

echo "[auto_sync] Push"
git push origin main || true

echo "[auto_sync] COMPLETATO"
