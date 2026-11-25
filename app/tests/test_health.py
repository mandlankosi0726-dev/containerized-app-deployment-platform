from fastapi.testclient import TestClient

from platformops.main import app


def test_health_liveness_and_readiness() -> None:
    with TestClient(app) as client:
        assert client.get("/health").json() == {"status": "ok"}
        assert client.get("/live").json() == {"status": "alive"}
        assert client.get("/ready").json() == {"status": "ready"}


def test_readiness_fails_when_app_is_not_ready() -> None:
    with TestClient(app) as client:
        app.state.ready = False
        response = client.get("/ready")
        assert response.status_code == 503
        app.state.ready = True
