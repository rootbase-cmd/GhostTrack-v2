<!DOCTYPE html>
<html lang="it">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>GhostTrack Hub</title>

<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css">

<style>
body {
  margin: 0;
  padding: 0;
  background: #0a0a0a;
  color: #e0e0e0;
  font-family: Arial, sans-serif;
}

header {
  padding: 20px;
  text-align: center;
  background: #111;
  border-bottom: 1px solid #222;
}

h1 {
  margin: 0;
  font-size: 28px;
  color: #00e0ff;
}

.panel {
  margin: 20px;
  padding: 20px;
  background: #111;
  border-radius: 12px;
  border: 1px solid #222;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.panel-title {
  font-size: 20px;
  font-weight: bold;
  color: #00e0ff;
}

.panel-badge {
  background: #00e0ff;
  color: #000;
  padding: 4px 10px;
  border-radius: 6px;
  font-size: 12px;
}

.hero-title {
  font-size: 22px;
  margin-top: 10px;
  color: #fff;
}

.hero-subtitle {
  font-size: 14px;
  color: #aaa;
  margin-bottom: 10px;
}
</style>
</head>

<body>
<header>
  <h1>GhostTrack Hub</h1>
</header>
<section class="panel" id="geo-sentinel">
  <div class="panel-header">
    <div class="panel-title">Geo‑Sentinel</div>
    <div class="panel-badge">Offline Maps</div>
  </div>

  <div class="hero-title">Mappe Offline & Monitoraggio Territoriale</div>
  <div class="hero-subtitle">
    Visualizzazione locale, resiliente e indipendente da API esterne.
  </div>

  <div id="map" style="height: 380px; border-radius: 12px; margin-top: 10px;"></div>

  <p style="margin-top:10px; font-size:12px; color:#888;">
    Le mappe offline sono caricate da <code>docs/maps/</code>.
  </p>
</section>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

<script>
function initGeoSentinel() {
  const mapEl = document.getElementById('map');
  if (!mapEl) return;

  const map = L.map('map', {
    zoomControl: true,
    attributionControl: false
  }).setView([45.0, 9.0], 10);

  const offlineTiles = L.tileLayer('./maps/tiles/{z}/{x}/{y}.png', {
    minZoom: 1,
    maxZoom: 18,
    errorTileUrl: './maps/blank.png'
  });

  offlineTiles.addTo(map);

  fetch('./maps/region.geojson')
    .then(r => r.json())
    .then(data => {
      L.geoJSON(data, {
        style: { color: '#00b7ff', weight: 2 }
      }).addTo(map);
    })
    .catch(() => {
      console.log('[GeoSentinel] Nessun GeoJSON trovato.');
    });
}

initGeoSentinel();
</script>
<section class="panel" id="boinc-hub">
  <div class="panel-header">
    <div class="panel-title">BOINC Hub</div>
    <div class="panel-badge">Compute</div>
  </div>
  <div class="hero-title">Calcolo distribuito</div>
  <div class="hero-subtitle">
    Accesso rapido ai progetti BOINC reali.
  </div>
  <ul>
    <li><a href="https://boinc.berkeley.edu/projects.php" target="_blank">Elenco progetti BOINC</a></li>
    <li><a href="https://einsteinathome.org" target="_blank">Einstein@Home</a></li>
    <li><a href="https://universeathome.pl" target="_blank">Universe@Home</a></li>
  </ul>
</section>

<section class="panel" id="seti-hub">
  <div class="panel-header">
    <div class="panel-title">SETI / Radio</div>
    <div class="panel-badge">Signals</div>
  </div>
  <div class="hero-title">Osservazione radio</div>
  <div class="hero-subtitle">
    Collegamenti a risorse reali per radioastronomia e segnali.
  </div>
  <ul>
    <li><a href="https://www.radio-astronomy.org" target="_blank">Società di Radioastronomia</a></li>
    <li><a href="http://websdr.org" target="_blank">WebSDR pubblici</a></li>
    <li><a href="https://sara.org" target="_blank">SARA</a></li>
  </ul>
</section>

<section class="panel" id="mesh-tools">
  <div class="panel-header">
    <div class="panel-title">Mesh & Tools</div>
    <div class="panel-badge">Network</div>
  </div>
  <div class="hero-title">Strumenti operativi</div>
  <div class="hero-subtitle">
    Collegamenti a strumenti reali per rete, diagnostica, OSINT.
  </div>
  <ul>
    <li><a href="https://web.telegram.org" target="_blank">Telegram Web</a></li>
    <li><a href="https://signal.org" target="_blank">Signal</a></li>
    <li><a href="https://onionsearchengine.com" target="_blank">Onion Search (OSINT)</a></li>
    <li><a href="https://nmap.online" target="_blank">Nmap Online</a></li>
  </ul>
</section>
<section class="panel" id="console-panel">
  <div class="panel-header">
    <div class="panel-title">Console Operativa</div>
    <div class="panel-badge">Shell</div>
  </div>
  <div class="hero-title">Console locale</div>
  <div class="hero-subtitle">
    Esegue comandi base lato browser: ping HTTP, apertura link, echo.
  </div>

  <div style="background:#000; color:#0f0; padding:10px; border-radius:8px; font-family:monospace; font-size:12px; height:180px; overflow:auto;" id="console-output">
    GhostTrack Console pronta. Digita "help" per i comandi disponibili.
  </div>
  <input id="console-input" type="text" placeholder="comando..." style="width:100%; margin-top:8px; padding:6px; border-radius:6px; border:1px solid #333; background:#050505; color:#eee;">
</section>

<script>
(function() {
  const outEl = document.getElementById('console-output');
  const inEl  = document.getElementById('console-input');
  if (!outEl || !inEl) return;

  function log(line) {
    outEl.textContent += "\n" + line;
    outEl.scrollTop = outEl.scrollHeight;
  }

  async function runCommand(cmd) {
    const parts = cmd.trim().split(" ");
    const base = parts[0];

    if (!base) return;

    if (base === "help") {
      log("Comandi disponibili:");
      log("  help                - mostra questo aiuto");
      log("  echo <testo>        - stampa testo");
      log("  open <url>          - apre URL in nuova scheda");
      log("  ping <url>          - invia richiesta HTTP GET");
      return;
    }

    if (base === "echo") {
      log(parts.slice(1).join(" "));
      return;
    }

    if (base === "open") {
      const url = parts[1];
      if (!url) { log("Uso: open <url>"); return; }
      window.open(url, "_blank");
      log("Apro: " + url);
      return;
    }

    if (base === "ping") {
      const url = parts[1];
      if (!url) { log("Uso: ping <url>"); return; }
      try {
        await fetch(url, { method: "GET", mode: "no-cors" });
        log("Ping inviato a: " + url);
      } catch (e) {
        log("Errore ping: " + e);
      }
      return;
    }

    log("Comando non riconosciuto. Digita 'help'.");
  }

  inEl.addEventListener("keydown", function(e) {
    if (e.key === "Enter") {
      const cmd = inEl.value;
      log("> " + cmd);
      inEl.value = "";
      runCommand(cmd);
    }
  });
})();
</script>

</body>
</html>
