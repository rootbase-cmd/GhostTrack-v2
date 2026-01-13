import requests
def test_status():
    r = requests.get("http://127.0.0.1:9090/api/status")
    assert r.status_code == 200
