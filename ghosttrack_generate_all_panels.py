import os

BASE_DIR = "webapp/static/panels"

modules = {
    "cyberdefense": [
        ("ThreatWatch", "threatwatch"),
        ("Intrusion Sentinel", "intrusionsentinel"),
        ("Network Shield", "networkshield"),
        ("ZeroTrust Layer", "zerotrust"),
        ("Integrity Guardian", "integrityguardian"),
        ("SecureMesh", "securemesh"),
    ],
    "orbital": [
        ("OrbitalWatch", "orbitalwatch"),
        ("Satellite Tracker", "satellite_tracker"),
        ("TLE Engine", "tle_engine"),
        ("SpaceWeather Monitor", "spaceweather"),
        ("StarlinkNode", "starlinknode"),
        ("DeepSpace Monitor", "deepspace_monitor"),
    ],
    "agro": [
        ("AgroWatch", "agrowatch"),
        ("Microclima Node", "microclima_node"),
        ("SoilSense", "soilsense"),
        ("RainPulse", "rainpulse"),
        ("WindWatch", "windwatch"),
        ("ForestGuard", "forestguard"),
        ("GeoSentinel", "geosentinel"),
    ],
    "calcolo": [
        ("BOINCNode", "boincnode"),
        ("SETI Node", "setinode"),
        ("Distributed Compute Engine", "distributed_compute_engine"),
        ("GPU Compute Layer", "gpu_compute_layer"),
        ("AI Local Engine", "ai_local_engine"),
    ],
    "radio": [
        ("RadioScan", "radioscan"),
        ("SDRWatch", "sdrwatch"),
        ("Spectrum Analyzer", "spectrum_analyzer"),
        ("SignalPulse", "signalpulse"),
        ("Beacon Listener", "beacon_listener"),
    ],
    "anonimato": [
        ("TorNode", "tornode"),
        ("I2PNode", "i2pnode"),
        ("PrivacyMesh", "privacymesh"),
        ("StealthRoute", "stealthroute"),
    ],
    "reti": [
        ("MeshNode", "meshnode"),
        ("LinkWatch", "linkwatch"),
        ("NetPulse", "netpulse"),
        ("MultiWAN Engine", "multiwan_engine"),
        ("Fallback System", "fallback_system"),
    ],
    "performance": [
        ("RedBull Mode", "redbull_mode"),
        ("TurboRitual", "turboritual"),
        ("FastCache", "fastcache"),
        ("IO Booster", "io_booster"),
    ],
    "core": [
        ("NodeCore", "nodecore"),
        ("RitualEngine", "ritualengine"),
        ("TelemetryCore", "telemetrycore"),
        ("LogEngine", "logengine"),
        ("ConfigSystem", "configsystem"),
        ("RepairEngine", "repairengine"),
        ("SyncEngine", "syncengine"),
    ],
    "moduli": [
        ("SportExtreme", "sportextreme"),
        ("SOSBeacon", "sosbeacon"),
        ("SOS Button", "sos_button"),
        ("Emergency Pulse", "emergency_pulse"),
        ("DistressSignal Node", "distresssignal_node"),
        ("WeatherNode", "weathernode"),
        ("GeoLocator", "geolocator"),
        ("EventWatch", "eventwatch"),
        ("TimeSync", "timesync"),
    ],
    "media": [
        ("LiveStream", "livestream"),
        ("Snapshot Engine", "snapshot_engine"),
        ("CamNode", "camnode"),
        ("WebRTC Feed", "webrtc_feed"),
    ],
    "chat": [
        ("RetroChat Terminal", "retrochat_terminal"),
        ("EventFeed", "eventfeed"),
        ("MatrixNode", "matrixnode"),
        ("MQTTNode", "mqttnode"),
    ],
    "mappe": [
        ("LiveAtlas", "liveatlas"),
        ("GeoMap Engine", "geomap_engine"),
        ("TerrainWatch", "terrainwatch"),
        ("HeatMap Layer", "heatmap_layer"),
    ],
    "resilienza": [
        ("FailSafe", "failsafe"),
        ("AutoRepair", "autorepair"),
        ("BackupRitual", "backupritual"),
        ("RecoveryNode", "recoverynode"),
        ("Watchdog Engine", "watchdog_engine"),
        ("SOSBeacon (Rescue)", "sosbeacon_rescue"),
        ("SOS Button (Rescue)", "sos_button_rescue"),
        ("Emergency Pulse (Rescue)", "emergency_pulse_rescue"),
        ("DistressSignal (Rescue)", "distresssignal_rescue"),
    ],
    "storage": [
        ("DataVault", "datavault"),
        ("LogVault", "logvault"),
        ("ArchiveEngine", "archiveengine"),
        ("SnapshotFS", "snapshotfs"),
    ],
    "osservazione": [
        ("SkyWatch", "skywatch"),
        ("EarthWatch", "earthwatch"),
        ("NightScan", "nightscan"),
        ("MotionSense", "motionsense"),
        ("AnomalyDetector", "anomalydetector"),
    ],
    "ai": [
        ("LocalAI", "localai"),
        ("PatternEngine", "patternengine"),
        ("PredictiveNode", "predictivenode"),
        ("AnomalyAI", "anomalyai"),
    ],
    "lab": [
        ("GhostTrack-Lab", "ghosttrack_lab"),
        ("ProtoNode", "protonode"),
        ("SensorForge", "sensorforge"),
        ("Experimental Mesh", "experimental_mesh"),
    ],
}

TEMPLATE = """<div class="panel">
  <h2>{icon} {title}</h2>
  <p class="subtitle">{subtitle}</p>

  <div class="widget">
    <h3>Stato modulo</h3>
    <p class="status">Modalità: <span data-field="mode">--</span></p>
  </div>

  <div class="widget">
    <h3>Dati / Telemetria</h3>
    <pre data-field="data">Nessun dato disponibile. Collegare questo pannello a un endpoint API per attivarlo.</pre>
  </div>

  <div class="widget">
    <h3>Note operative</h3>
    <p class="notes">
      Modulo parte della costellazione GhostTrack‑v2. Questo pannello è pronto per essere collegato a dati reali
      o a simulazioni locali, in base al contesto del nodo.
    </p>
  </div>
</div>
"""

ICONS = {
    "cyberdefense": "🌐",
    "orbital": "🛰",
    "agro": "🌾",
    "calcolo": "🧮",
    "radio": "📡",
    "anonimato": "🕳",
    "reti": "🌍",
    "performance": "🔥",
    "core": "🧱",
    "moduli": "🧩",
    "media": "🎥",
    "chat": "💬",
    "mappe": "🗺",
    "resilienza": "🛡",
    "storage": "📦",
    "osservazione": "🔭",
    "ai": "🧠",
    "lab": "🧪",
}

SUBTITLES = {
    "cyberdefense": "Protezione, integrità e sicurezza del nodo.",
    "orbital": "Gestione dati satellitari e spaziali.",
    "agro": "Monitoraggio microclima, suolo e territorio.",
    "calcolo": "Calcolo distribuito e ricerca scientifica.",
    "radio": "Analisi e osservazione dello spettro radio.",
    "anonimato": "Anonimato, privacy e routing sicuro.",
    "reti": "Connettività resiliente e mesh networking.",
    "performance": "Ottimizzazione prestazioni e modalità RedBull.",
    "core": "Cuore operativo del nodo GhostTrack.",
    "moduli": "Estensioni funzionali e rituali avanzati.",
    "media": "Streaming, snapshot e feed video.",
    "chat": "Chat, feed eventi e messaggistica.",
    "mappe": "Mappe, atlanti e visualizzazioni geografiche.",
    "resilienza": "FailSafe, emergenza e continuità operativa.",
    "storage": "Dati, log, archivi e snapshot.",
    "osservazione": "Osservazione cielo, terra e anomalie.",
    "ai": "Analisi, pattern e intelligenza locale.",
    "lab": "Sperimentazione e protocolli in sviluppo.",
}

os.makedirs(BASE_DIR, exist_ok=True)

for domain, items in modules.items():
    domain_dir = os.path.join(BASE_DIR, domain)
    os.makedirs(domain_dir, exist_ok=True)
    icon = ICONS.get(domain, "📘")
    subtitle = SUBTITLES.get(domain, "Modulo della costellazione GhostTrack‑v2.")
    for title, slug in items:
        path = os.path.join(domain_dir, f"{slug}.html")
        if os.path.exists(path):
            continue
        html = TEMPLATE.format(icon=icon, title=title, subtitle=subtitle)
        with open(path, "w", encoding="utf-8") as f:
            f.write(html)
        print("Creato pannello:", path)
