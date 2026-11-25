# Project checklist

Status key: `[x]` validated, `[~]` implemented but validation is blocked or partial, `[ ]` not complete.

| Phase | Scope | Status | Evidence / remaining work |
| --- | --- | --- | --- |
| 1 | Architecture and repository foundation | [x] | Blank workspace inspected; architecture, lifecycle, ADRs and checklist recorded. |
| 2 | FastAPI application | [x] | 8 tests pass; 99.19% coverage; Ruff passes; container API smoke passes. |
| 3 | Docker and Compose | [~] | Image `platformops-deployment-platform:v0.1.0` built (260 MB); non-root, healthy, endpoint/restart/graceful-stop smoke passes; Compose config passes. Image vulnerability DB download was interrupted, so image CVE status is unknown. |
| 4 | Kubernetes foundation | [~] | Kind v1.31.4 cluster created; Helm Deployment reported 2/2 rollout and security settings verified. Control plane later became unhealthy from etcd/API timeouts; project node is stopped, not deleted. |
| 5 | Networking | [~] | Client Pod resolved service DNS and `/health` returned 200; loopback port-forward passed all endpoints. NetworkPolicy enforcement was not independently tested. |
| 6 | Helm | [~] | Dev and production lint/template pass; Helm install succeeded. A subsequent baseline upgrade failed with API context deadline; no rollback was demonstrated. |
| 7 | CI/CD | [~] | CI/build/security workflows and least-privilege GHCR permissions added; YAML parses. No GitHub remote or Actions run was available. |
| 8 | Deployment automation | [~] | Build/deploy scripts and local Helm rollout succeeded once. The later upgrade/recovery path could not complete while etcd was failing. |
| 9 | Monitoring | [~] | Prometheus/Grafana configs, dashboard and alert rules added; app metrics were collected in unit/container/cluster endpoint responses. No Prometheus scrape or Grafana dashboard was observed running. |
| 10 | Security review | [~] | Trivy config scans report 0 findings for rendered base/Helm/Dockerfile config; app image scan did not finish; GitHub scans are unexecuted. |
| 11 | Troubleshooting lab | [~] | Diagnosed DNS/service path and real etcd slow-fsync/API timeout failure; no application image-pull failure or successful Helm rollback was completed. |
| 12 | Final review | [~] | Docs and static checks reviewed; current environment/runtime limits and exact outcomes recorded in `docs/validation-results.md`. |

The original selected kubeconfig context was `minikube`. Kind temporarily selected `kind-platformops`; it was explicitly restored to `minikube` after validation. No commands were run against the Minikube context.

No Kubernetes, container, metrics, CI execution or rollback result is considered validated until exercised. The existing kubectl context is Minikube and must remain untouched; this project will use a separately named Kind cluster.
