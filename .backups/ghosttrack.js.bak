// docs/assets/js/ghosttrack.js

// =========================
// 1) TAB ENGINE
// =========================
(function () {
  const tabs = document.querySelectorAll('.tab');
  const panels = document.querySelectorAll('.panel');

  function activateTab(targetId) {
    tabs.forEach(t => t.classList.remove('active'));
    panels.forEach(p => p.style.display = 'none');
    const tab = document.querySelector(`.tab[data-target="${targetId}"]`);
    const panel = document.getElementById(targetId);
    if (tab) tab.classList.add('active');
    if (panel) panel.style.display = 'block';
  }

  tabs.forEach(tab => {
    tab.addEventListener('click', () => {
      const target = tab.dataset.target;
      activateTab(target);
      if (target === 'env') GhostTrackEnv.requestUpdate();
    });
  });

  // pannello di default
  activateTab('mission');
})();

// =========================
// 2) CHAT LOCALE
// =========================
const GhostTrackChat = (function () {
  const chatLog = document.getElementById('chatlog');
  const chatInput = document.getElementById('chatinput');

  function append(role, text) {
    if (!chatLog) return;
    chatLog.innerHTML += `<div><b>${role}:</b> ${text}</div>`;
    chatLog.scrollTop = chatLog.scrollHeight;
  }

  function init() {
    if (!chatInput) return;
    chatInput.addEventListener('keydown', e => {
      if (e.key !== 'Enter') return;
      const msg = chatInput.value.trim();
      if (!msg) return;
      append('Tu', msg);
      chatInput.value = '';
      setTimeout(() => {
        append('Nodo', 'Ricevuto. Modalità offline demo.');
      }, 300);
    });
  }

  init();
  return { append };
})();

// =========================
// 3) CREDITO ENERGETICO
// =========================
const GhostTrackEnergy = (function () {
  let state = {
    value: 0,
    level: 'Seed',
    log: []
  };

  function updateLevel() {
    const v = state.value;
    if (v < 50) state.level = 'Seed';
    else if (v < 150) state.level = 'Node';
    else if (v < 300) state.level = 'Constellation';
    else state.level = 'Mythic';
  }

  function render() {
    updateLevel();
    const box = document.getElementById('energy-current');
    const logBox = document.getElementById('energy-log');
    if (!box || !logBox) return;
    box.innerHTML = `
      <b>Energia:</b> ${state.value} CE<br>
      <b>Livello:</b> ${state.level}<br>
    `;
    logBox.textContent = state.log.join('\n') || '[log] Nessun evento ancora.';
  }

  function log(msg) {
    const ts = new Date().toISOString().slice(0, 19).replace('T', ' ');
    state.log.unshift(`[${ts}] ${msg}`);
    if (state.log.length > 8) state.log.pop();
    render();
  }

  function event(type) {
    switch (type) {
      case 'uptime-tick':
        state.value += 1;
        log('+1 CE — uptime nodo');
        break;
      case 'obs-session':
        state.value += 5;
        log('+5 CE — sessione osservazione');
        break;
      case 'mesh-sync':
        state.value += 3;
        log('+3 CE — sync mesh');
        break;
      case 'heavy-ritual':
        state.value -= 2;
        log('-2 CE — rituale pesante');
        break;
    }
    if (state.value < 0) state.value = 0;
    render();
  }

  // tick simbolico ogni minuto
  setInterval(() => event('uptime-tick'), 60000);
  render();

  return { event, render };
})();

// =========================
// 4) ENVIRONMENT (Open-Meteo)
// =========================
const GhostTrackEnv = (function () {
  const api = {
    weather: 'https://api.open-meteo.com/v1/forecast',
    air: 'https://air-quality-api.open-meteo.com/v1/air-quality'
  };
  const microclimaBox = document.getElementById('microclima');
  const agroBox = document.getElementById('agro');

  async function update(lat, lon) {
    try {
      const weatherUrl =
        `${api.weather}?latitude=${lat}&longitude=${lon}` +
        `&current=temperature_2m,relative_humidity_2m,pressure_msl,wind_speed_10m`;
      const airUrl =
        `${api.air}?latitude=${lat}&longitude=${lon}` +
        `&hourly=pm10,pm2_5,carbon_monoxide,ozone`;

      const [wRes, aRes] = await Promise.all([fetch(weatherUrl), fetch(airUrl)]);
      const wData = await wRes.json();
      const aData = await aRes.json();
      const c = wData.current || {};
      const h = aData.hourly || {};
      if (microclimaBox) {
        microclimaBox.innerHTML = `
          <b>Lat:</b> ${lat.toFixed(4)}<br>
          <b>Lon:</b> ${lon.toFixed(4)}<br>
          <b>Temperatura:</b> ${c.temperature_2m ?? 'n/d'} °C<br>
          <b>Umidità:</b> ${c.relative_humidity_2m ?? 'n/d'} %<br>
          <b>Pressione:</b> ${c.pressure_msl ?? 'n/d'} hPa<br>
          <b>Vento:</b> ${c.wind_speed_10m ?? 'n/d'} km/h
        `;
      }
      if (agroBox) {
        const idx = 0;
        agroBox.innerHTML = `
          <span class="badge badge-ok">SoilSense</span>
          <span class="badge badge-ok">RainPulse</span>
          <span class="badge badge-warn">WindWatch</span><br>
          <span class="badge badge-off">ForestGuard</span>
          <span class="badge badge-off">GeoSentinel</span>
          <p class="small">
            PM10: ${h.pm10 ? h.pm10[idx] : 'n/d'} µg/m³<br>
            PM2.5: ${h.pm2_5 ? h.pm2_5[idx] : 'n/d'} µg/m³<br>
            CO: ${h.carbon_monoxide ? h.carbon_monoxide[idx] : 'n/d'} µg/m³<br>
            Ozono: ${h.ozone ? h.ozone[idx] : 'n/d'} µg/m³
          </p>
        `;
      }
    } catch (e) {
      if (microclimaBox) {
        microclimaBox.innerHTML = '<b>Errore:</b> impossibile contattare le API.';
      }
    }
  }

  function requestUpdate() {
    if (!navigator.geolocation) {
      if (microclimaBox) {
        microclimaBox.innerHTML = '<b>Errore:</b> Geolocalizzazione non supportata.';
      }
      return;
    }
    navigator.geolocation.getCurrentPosition(
      pos => update(pos.coords.latitude, pos.coords.longitude),
      () => {
        if (microclimaBox) {
          microclimaBox.innerHTML = '<b>Errore:</b> Geolocalizzazione negata o fallita.';
        }
      }
    );
  }

  return { requestUpdate };
})();

// =========================
// 5) ISS + MOON
// =========================
const GhostTrackSpace = (function () {
  const issBox = document.getElementById('isspos');
  const moonBox = document.getElementById('moonphase');

  function loadISS() {
    if (!issBox) return;
    fetch('http://api.open-notify.org/iss-now.json')
      .then(r => r.json())
      .then(d => {
        const lat = d.iss_position.latitude;
        const lon = d.iss_position.longitude;
        issBox.innerHTML = `Lat: ${lat}<br>Lon: ${lon}`;
      })
      .catch(() => {
        issBox.innerHTML = 'Impossibile ottenere dati ISS.';
      });
  }

  function loadMoon() {
    if (!moonBox) return;
    fetch('https://api.open-meteo.com/v1/forecast?latitude=45&longitude=9&daily=moon_phase&timezone=auto')
      .then(r => r.json())
      .then(d => {
        const phase = d.daily && d.daily.moon_phase ? d.daily.moon_phase[0] : 'n/d';
        moonBox.innerHTML = 'Fase lunare: ' + phase;
      })
      .catch(() => {
        moonBox.innerHTML = 'Impossibile ottenere dati lunari.';
      });
  }

  loadISS();
  loadMoon();
  return { loadISS, loadMoon };
})();

// =========================
// 6) TELEMETRIA (STUB)
// =========================
const GhostTrackTelemetry = (function () {
  const box = document.getElementById('node-telemetry');

  async function load() {
    // in futuro: leggere docs/telemetry.json
    if (!box) return;
    box.innerHTML = `
      <b>Uptime:</b> demo<br>
      <b>Load Avg:</b> demo<br>
      <b>Disco:</b> demo<br>
      <b>IP:</b> demo<br>
      <b>Status:</b> <span class="badge badge-ok">OK</span>
    `;
  }

  load();
  return { load };
})();

// =========================
// 7) AUTH (STUB CONCETTUALE)
// =========================
// Qui potresti in futuro agganciare un provider esterno.
// Con sola pagina statica non fai OAuth completo in sicurezza.
// Manteniamo solo un hook simbolico.

const GhostTrackAuth = (function () {
  let operatorMode = false;

  function enableOperatorMode(code) {
    if (code === 'GHOST-PRAGONE') {
      operatorMode = true;
      alert('Operator mode attivata (locale, simbolica).');
      GhostTrackEnergy.event('obs-session');
    } else {
      alert('Codice non valido.');
    }
  }

  return { enableOperatorMode };
})();

/* GhostTrack Menu Module */
const GhostTrackMenu = {
  toggle() {
    const panel = document.getElementById("menuPanel");
    if (!panel) return console.warn("menuPanel non trovato");
    panel.style.display = panel.style.display === "none" ? "block" : "none";
    if (panel.style.display === "block") panel.scrollIntoView({behavior: "smooth"});
  }
};
