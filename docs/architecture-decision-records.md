# Architecture decision records

## ADR-001: Docker image as the workload unit

**Decision:** Package the FastAPI service as an OCI image. **Alternatives:** run directly on the host or use a VM image. **Trade-off:** reproducible runtime and Kubernetes portability in exchange for image build and scanning maintenance.

## ADR-002: Kind for local Kubernetes

**Decision:** Use a named Kind cluster for the default cluster exercise. **Alternatives:** managed cloud Kubernetes or existing workstation cluster. **Trade-off:** no cloud expense and reproducible control plane, but no multi-node production guarantees and reliance on local container runtime access.

## ADR-003: Helm for application releases

**Decision:** Helm manages parameterized releases and revision history. **Alternative:** apply static YAML only. **Trade-off:** values and templating add a learning surface, while upgrades and rollbacks become repeatable.

## ADR-004: GHCR for trusted images

**Decision:** GitHub Container Registry with the workflow's scoped `GITHUB_TOKEN`. **Alternatives:** Docker Hub or self-hosted registry. **Trade-off:** native GitHub identity and permissions, with repository tied to GitHub for publication.

## ADR-005: Stateless application

**Decision:** Keep request handling and telemetry in memory; do not persist user data. **Alternative:** attach a database or volume. **Trade-off:** easy replacement and scaling; process-local metrics reset on restart and are not an application data store.

## ADR-006: CI checks before publishing

**Decision:** Run lint, tests, chart/manifests checks, build and scan on pull requests; publish only from trusted pushes/tags. **Trade-off:** avoid untrusted registry writes, while deployment to local Kind remains a developer-controlled action.

## ADR-007: Prometheus metrics and optional Grafana

**Decision:** Expose standard app metrics and make a local Prometheus/Grafana stack optional. **Alternative:** install a full observability distribution by default. **Trade-off:** smaller baseline; cluster metrics and dashboards require separately installed components.

## ADR-008: Baseline pod security and resource bounds

**Decision:** Non-root UID, read-only root FS, dropped capabilities, seccomp RuntimeDefault, explicit resource requests/limits and probes. **Trade-off:** stronger default isolation; adding writable paths or capabilities later requires explicit design.
