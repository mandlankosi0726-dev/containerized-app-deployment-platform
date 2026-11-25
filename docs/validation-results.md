# Validation results

Run date: 25 November 2026 (Africa/Johannesburg). This report distinguishes successful checks from capabilities that could not be completed in the local environment.

## Passed

- Application: Ruff lint and format checks passed. `pytest app/tests` passed **8 tests** with **99.19% coverage** (Python 3.14.10 in the local venv). Tests cover health/readiness/liveness, safe metadata, Prometheus exposition, 404 handling and sanitized 500 responses.
- Image: `scripts/build-image.sh v0.1.0` built `platformops-deployment-platform:v0.1.0` from Python 3.12.8. Image inspection reported UID/GID `10001:10001` and size **260,084,335 bytes**. The image was given a unique project name; a pre-existing unrelated `platformops:dev` image was left untouched.
- Container: `scripts/container-smoke.sh` reached Docker health state `healthy`; all app endpoints and the Prometheus metric endpoint returned success. The script verified UID 10001, restart recovery, resource display and graceful shutdown with exit code 0. It removed only its own temporary container and retained the image.
- Kustomize and packaging: `kubectl kustomize kubernetes/overlays/development` passed. Helm v3.17.3 lint passed for development and production values; templates rendered for both. Helm installed revision 1 into the dedicated cluster, and the Deployment reported **2/2 ready replicas**.
- Static config: `docker compose -f docker/compose.yaml config` passed. Trivy configuration scans found **0 high/critical misconfigurations** in the scanned Kubernetes base, Helm templates and Dockerfile. YAML parsing passed for 21 YAML files; the Grafana dashboard JSON parsed successfully.
- Cluster networking: from a temporary unselected client Pod, DNS resolved `platformops` to `10.96.221.199` and an HTTP request to the Service returned `{"status":"ok"}`. A loopback-only port-forward validated `/health`, `/live`, `/ready`, `/api/v1/info`, `/api/v1/system`, and `/metrics`. The temporary diagnostic Pod was deleted.
- Ansible: the read-only preflight playbook passed with `changed=0`, reporting Docker, kubectl, Kind, Helm and Python available.
- Context safety: Kind selected its context during creation. The original selected context `minikube` was restored afterward; all project `kubectl` operations explicitly used `kind-platformops`.

## Incomplete or failed

- Vulnerability scan: `trivy image --scanners vuln --severity HIGH,CRITICAL --exit-code 1 platformops-deployment-platform:v0.1.0` began downloading the 136.84 MiB database, reached about 13.55 MiB as transfer speed fell below 300 KiB/s, and was stopped. **No image vulnerability result is available.** The workflow is configured to scan before publication.
- CI/CD: workflow YAML parsed, but no GitHub remote was configured in the empty workspace, so no Actions run or GHCR publication was possible. Publication is not claimed as validated.
- Monitoring: `/metrics` was exercised in tests and the container/cluster. Prometheus, Grafana, and alert manifests were added, but no running Prometheus scrape, Grafana dashboard, or alert firing was observed.
- HPA: chart configuration is present but disabled in development. Metrics Server was not installed and autoscaling was not tested. Manual scaling was not completed.
- Helm upgrade/rollback: after the successful initial install, a baseline configuration upgrade timed out while the cluster's etcd/API degraded. Helm recorded revision 2 as failed. The deliberate bad-image injection was therefore **not run**, and rollback was **not demonstrated**.
- Cluster stability: node logs showed etcd `slow fdatasync` around 4 seconds, linearizable reads over 13 seconds, API timeouts and controller-manager/scheduler CrashLoopBackOff. Restarting only the project node did not restore API health. To protect the shared workstation, `platformops-control-plane` was stopped with its state retained. The cluster was not deleted. The selected context remains `minikube`.
- Host tooling: `make` is unavailable, so the equivalent commands were run directly. Git metadata and a GitHub remote were absent.

No AWS resources, production deployment, public listener, or cloud charge was created. No Docker image, pre-existing container, volume, unrelated cluster, or unrelated Kubernetes resource was deleted.

## To resume

Inspect host load and disk latency first. The named Kind container still exists but is stopped; inspect its identity before starting it. If it recovers, verify `/readyz`, kube-system Pods, Helm history and app rollout before continuing. Run `scripts/rollback-lab.sh v0.1.0` only after a known-good release is healthy. Complete a Prometheus scrape check, HPA only after installing/validating metrics-server, and the image scan when the vulnerability database can be downloaded at a usable rate.
