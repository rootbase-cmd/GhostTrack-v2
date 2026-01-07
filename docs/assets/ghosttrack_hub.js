// GhostTrack Hub JS
// Live console · Meteo reale · Hooks BOINC/SETI · Hub modulare

// =========================
// UTILITÀ DI BASE
// =========================

function $(selector) {
  return document.querySelector(selector);
}

function safeEl(id) {
  return document.getElementById(id);
}

function setStatus(dotEl, statusClass) {
  if (!dotEl) return;
  dotEl.classList.remove('status-ok', 'status-warn', 'status-off');
  dotEl.classList.add(statusClass);
}

// =========================
// CONSOLE INTERATTIVA
// =========================

function initConsole() {
  const terminalBody = safeEl('terminal-body');
  const startRitualBtn = safeEl('btn-start-ritual');
  if (!terminalBody || !startRitualBtn) return;

  function appendToTerminal(lines) {
    const frag = document.createDocumentFragment();
    lines.forEach(line => {
      const span = document.createElement('span');
      span.innerHTML = line;
      frag.appendChild(span);
      frag.appendChild(document.createElement('br'));
    });
    // inseriamo prima del cursore lampeggiante (ultimo nodo)
    const lastChild = terminalBody.lastChild;
    terminalBody.insertBefore(frag, lastChild);
    terminalBody.scrollTop = terminalBody.scrollHeight;
  }

  startRitualBtn.addEventListener('click', () => {
    appendToTerminal([
      '<span class="prompt">ghosttrack</span><span class="prompt-symbol">@room</span>:<span class="prompt-path">~/rituals</span>$ <span class="cmd">./ghost_ritual_orbit_demo.sh --safe</span>',
      '<span class="output-ok">[RITUAL] GhostTrack orbit ritual started in SAFE mode</span>',
      '<span class="output-muted">         Tutto simulato lato client. Nessuna azione reale.</span>'
    ]);
  });
}

// =========================
// METEO REALE (OPEN-METEO)
// =========================

function initMeteo() {
  const meteoDot = safeEl('meteo-dot');
  const meteoTemp = safeEl('meteo-temp');
  const meteoLabel = safeEl('meteo-label');
  if (!meteoDot || !meteoTemp || !meteoLabel) return;

  async function fetchRealMeteo() {
    try {
      // TODO: personalizza con le coordinate del tuo nodo (Pragone / Oltrepò)
      const lat = 45.47;
      const lon = 9.19;
      const url = `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current_weather=true`;

      const res = await fetch(url);
      const data = await res.json();

      if (!data.current_weather) {
        setStatus(meteoDot, 'status-warn');
        meteoTemp.textContent = 'N/D';
        meteoLabel.textContent = 'Meteo: dati non disponibili.';
        return;
      }

      const temp = data.current_weather.temperature;
      const wind = data.current_weather.windspeed;

      setStatus(meteoDot, 'status-ok');
      meteoTemp.textContent = `${temp}°C · vento ${wind} km/h`;
      meteoLabel.textContent = 'Dati meteo live · Open-Meteo';
    } catch (e) {
      setStatus(meteoDot, 'status-warn');
      meteoTemp.textContent = 'N/D';
      meteoLabel.textContent = 'Errore nel recupero dati meteo.';
    }
  }

  fetchRealMeteo();
  setInterval(fetchRealMeteo, 60000);
}

// =========================
// BOINC HUB (HOOK FUTURO)
// =========================

function initBoincHub() {
  const boincDot = safeEl('boinc-dot');
  const boincProgress = safeEl('boinc-progress');
  const boincLabel = safeEl('boinc-label');
  if (!boincDot || !boincProgress || !boincLabel) return;

  // Qui in futuro puoi collegare una tua API che espone:
  // - numero di task
  // - percentuale di completamento
  // - progetti attivi
  //
  // Esempio di struttura:
  //
  // fetch('https://tuo-backend/boinc/status')
  //   .then(r => r.json())
  //   .then(data => { ... });

  setStatus(boincDot, 'status-off');
  boincProgress.textContent = 'N/D';
  boincLabel.textContent = 'Hook pronto per nodo BOINC (API tua).';
}

// =========================
// SETI / RADIO HUB (HOOK FUTURO)
// =========================

function initSetiHub() {
  const setiDot = safeEl('seti-dot');
  const setiSignal = safeEl('seti-signal');
  const setiLabel = safeEl('seti-label');
  if (!setiDot || !setiSignal || !setiLabel) return;

  // Qui puoi collegare:
  // - backend che simula “signal strength”
  // - stato di un radiotelescopio software
  // - log di analisi
  //
  // Esempio:
  //
  // fetch('https://tuo-backend/seti/status')
  //   .then(r => r.json())
  //   .then(data => { ... });

  setStatus(setiDot, 'status-off');
  setiSignal.textContent = 'N/D';
  setiLabel.textContent = 'Hook pronto per backend radio / SETI-like.';
}

// =========================
// LIVE EMBEDS / HUB COMUNITARIO
// (qui puoi aggiungere logica extra se vuoi reagire agli embed)
// =========================

function initLiveEmbeds() {
  // Per ora gli embed (Red Bull, NASA, ISS) sono statici nell’HTML.
  // Qui puoi in futuro:
  // - cambiare canali dinamicamente
  // - ruotare playlist
  // - mostrare info contestuali (titolo evento, orario, ecc.)
  //
  // Esempio di idea:
  // const extremeSection = document.getElementById('extreme');
  // ...
}

// =========================
// INIZIALIZZAZIONE GLOBALE
// =========================

function initGhostTrackHub() {
  initConsole();
  initMeteo();
  initBoincHub();
  initSetiHub();
  initLiveEmbeds();
}

document.addEventListener('DOMContentLoaded', initGhostTrackHub);
