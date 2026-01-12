from flask import Flask, send_from_directory, jsonify
import pathlib

# Percorso della cartella static della UI
STATIC_DIR = pathlib.Path(__file__).resolve().parents[1] / "webapp" / "static"

app = Flask(
    __name__,
    static_folder=str(STATIC_DIR),
    static_url_path=""
)

# Endpoint API base
@app.route("/api/status")
def status():
    return jsonify({
        "status": "ok",
        "service": "GhostTrack WebApp",
        "version": "v3"
    })

# Routing UI (serve index.html per tutte le pagine)
@app.route("/", defaults={"path": ""})
@app.route("/<path:path>")
def serve(path):
    target = STATIC_DIR / path
    if path and target.exists():
        return send_from_directory(STATIC_DIR, path)
    return send_from_directory(STATIC_DIR, "index.html")

# Avvio locale
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=9090)
