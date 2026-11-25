# Docker and Compose

Build an immutable local tag with `./scripts/build-image.sh <git-sha-or-version>`. Run `docker compose -f docker/compose.yaml up --build`, then open `http://127.0.0.1:8000/health`. Compose binds only to loopback. `docker compose -f docker/compose.yaml logs -f api` follows logs; `docker compose -f docker/compose.yaml exec api id` verifies the runtime user; `docker stats` shows resource use. `docker inspect` displays health and configuration; stop with `docker compose -f docker/compose.yaml down` (does not remove images or volumes).

Compose uses a read-only filesystem, dropped capabilities, no-new-privileges, init, health checks, restart policy, and resource bounds. Docker's `HEALTHCHECK` also applies outside Compose. The image's entrypoint is Uvicorn and receives termination signals directly. Container shell access can be done with `docker exec -it <container> /bin/sh` when available; this slim image intentionally does not include debugging utilities.

For local metrics, start the API first, set a strong throwaway `GRAFANA_ADMIN_PASSWORD`, and run Compose with both `-f docker/compose.yaml -f docker/compose.monitoring.yaml up`. Prometheus and Grafana are loopback-bound; do not publish this demo monitoring stack publicly. Local application state and metrics are ephemeral.

Docker builds an image and runs one container. Compose coordinates a small local multi-container application and its local network. Kubernetes schedules and reconciles workloads across cluster nodes, manages service discovery and rollout history. Compose is not used for production orchestration.
