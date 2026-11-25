from fastapi.testclient import TestClient

from platformops.main import app


def test_metrics_are_prometheus_compatible() -> None:
    client = TestClient(app)
    client.get("/health")
    response = client.get("/metrics")
    assert response.status_code == 200
    assert "text/plain" in response.headers["content-type"]
    assert "platformops_http_requests_total" in response.text
    assert 'path="/health"' in response.text


def test_unknown_route_is_not_exposed_as_internal_error() -> None:
    response = TestClient(app).get("/does-not-exist")
    assert response.status_code == 404
    assert "Internal server error" not in response.text


def test_unexpected_error_is_sanitized() -> None:
    async def fail() -> None:
        raise RuntimeError("private failure detail")

    app.add_api_route("/_test/error", fail, methods=["GET"])
    try:
        response = TestClient(app, raise_server_exceptions=False).get("/_test/error")
    finally:
        app.router.routes = [route for route in app.router.routes if route.path != "/_test/error"]
    assert response.status_code == 500
    assert response.json() == {"detail": "Internal server error"}
    assert "private failure detail" not in response.text
