# PlatformOps API

FastAPI service used as a deliberately stateless Kubernetes workload. Settings are read from `APP_NAME`, `APP_VERSION`, `APP_ENVIRONMENT`, `BUILD_REVISION`, `BUILD_DATE`, and `LOG_LEVEL`; no other environment variables are returned by an endpoint.

Endpoints: `/`, `/health`, `/live`, `/ready`, `/api/v1/info`, `/api/v1/system`, `/metrics`. `/health` is a lightweight process health check, `/live` is suitable for a liveness probe, and `/ready` tracks application startup/shutdown readiness. The runtime endpoint returns Python version, OS family, and architecture only. `/metrics` excludes itself from request counters and labels paths with route templates to avoid unbounded cardinality.

Run with `python -m pip install -e 'app[dev]'` from the repository root, then `uvicorn platformops.main:app --app-dir app/src --host 127.0.0.1 --port 8000`. Run checks with `make app-check`.
