from fastapi.testclient import TestClient

from platformops.main import app


def test_landing_has_platform_metadata() -> None:
    payload = TestClient(app).get("/").json()
    assert payload["application"] == "PlatformOps API"
    assert payload["status"] == "running"
    assert payload["version"]


def test_info_has_build_and_runtime_fields() -> None:
    payload = TestClient(app).get("/api/v1/info").json()
    assert {
        "application",
        "version",
        "build_revision",
        "build_date",
        "environment",
    } <= payload.keys()
    assert "python_version" in payload


def test_system_does_not_return_environment() -> None:
    payload = TestClient(app).get("/api/v1/system").json()
    assert set(payload) == {"python_version", "operating_system", "architecture"}
    assert "environ" not in payload
