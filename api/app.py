from flask import Flask
import subprocess, json, time, requests

app = Flask(__name__)

# ============================
#  CORE STATUS
# ============================
@app.route("/api/status")
def api_status():
    return {
        "environment": "production",
        "service": "GhostTrack WebApp",
        "status": "ok",
        "timestamp": time.time(),
        "version": "3.0"
    }

# ============================
#  CYBERDEFENSE
# ============================
@app.route("/api/cyberdefense/status")
def cyberdefense_status():
    return {
        "module": "cyberdefense",
        "status": "online",
        "uptime": "API OK",
        "threats_detected": 0
    }

# ============================
#  ORBITAL & SPACE
# ============================
@app.route("/api/orbital_space/status")
def orbital_space_status():
    return {
        "module": "orbital_space",
        "status": "online",
        "satellites_visible": 12,
        "source": "GNSS simulation"
    }

# ============================
#  AGRO & AMBIENTE
# ============================
@app.route("/api/agro_ambiente/status")
def agro_ambiente_status():
    try:
        url = "https://api.open-meteo.com/v1/forecast?latitude=45.0&longitude=9.2&current_weather=true"
        data = requests.get(url).json()
        return {
            "module": "agro_ambiente",
            "status": "online",
            "temperature": data["current_weather"]["temperature"],
            "windspeed": data["current_weather"]["windspeed"],
            "weathercode": data["current_weather"]["weathercode"]
        }
    except:
        return {"module": "agro_ambiente", "status": "offline"}

# ============================
#  RESILIENZA
# ============================
@app.route("/api/resilienza/status")
def resilienza_status():
    return {
        "module": "resilienza",
        "status": "online",
        "heartbeat": "alive",
        "timestamp": time.time()
    }

# ============================
#  RETI & MESH
# ============================
@app.route("/api/reti_mesh/status")
def reti_mesh_status():
    target = "8.8.8.8"
    try:
        result = subprocess.run(["ping", "-c", "1", target], capture_output=True, text=True)
        if result.returncode == 0:
            latency = result.stdout.split("time=")[1].split(" ")[0]
            return {
                "module": "reti_mesh",
                "status": "online",
                "latency_ms": latency
            }
        else:
            return {"module": "reti_mesh", "status": "offline"}
    except:
        return {"module": "reti_mesh", "status": "error"}

# ============================
#  AI & ANALISI
# ============================
@app.route("/api/ai_analisi/status")
def ai_analisi_status():
    return {
        "module": "ai_analisi",
        "status": "online",
        "analysis": "ready",
        "confidence": 0.99
    }

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=9090)
