# Troubleshooting lab

Run fault scenarios only in the dedicated project Kind cluster or a local Compose project. Diagnose first, record the observed symptom, and restore a known-good image/configuration afterward. Do not use faults against shared clusters.

| Scenario | Symptoms and diagnostics | Likely cause and recovery |
| --- | --- | --- |
| Docker build failure | `docker build` output; `docker info`; inspect build context | Missing daemon/network/dependency. Check Dockerfile/context, restore daemon access, rebuild. |
| Container exits or port conflict | `docker ps -a`, `docker logs`, `ss -ltnp`, `docker inspect` | Bad command/config or host port already used. Correct input or choose another loopback host port. |
| Container cannot write | Health/startup errors; inspect read-only mode and container logs | Expected read-only root FS. Write only to a justified tmpfs path; do not disable filesystem protection broadly. |
| CrashLoopBackOff | `kubectl describe pod`, previous logs `kubectl logs --previous` | Process crash/config issue. Fix ConfigMap or image, then rollout. |
| ImagePullBackOff | Pod events and image reference | Missing tag or registry auth. For local Kind, load built tag and use `IfNotPresent`; never commit registry credentials. |
| Pending pod | `kubectl describe pod`, `kubectl get nodes`, `kubectl describe node` | Requests cannot fit, node unavailable or quota. Right-size requests or cluster capacity. |
| Probe failures | Pod events, `kubectl logs`, port/name and endpoint checks | Wrong path/port or app not ready. Match `/live`, `/ready`, 8000 and allow startup time. |
| Service unavailable | `kubectl get svc,endpoints`, `kubectl get pods --show-labels` | Selector mismatch or readiness false. Compare Service selector to Pod labels and inspect readiness. |
| DNS failure | `kubectl exec` and `nslookup` if available; inspect CoreDNS pods and egress policy | DNS service or policy issue. Permit UDP/TCP 53 and check cluster DNS. |
| Ingress failure | `kubectl get ingress`, controller logs, Service endpoints | Baseline has no controller/Ingress. Install a compatible controller and configure local host routing before testing. |
| HPA does not scale | `kubectl get hpa`, `kubectl describe hpa`, `kubectl top pods` | Metrics API missing or CPU requests absent. Install/verify metrics-server and keep CPU requests configured. |
| Registry authentication/push failure | Workflow log, package permissions, image name | `packages: write` or repository visibility/config error. Use trusted branch workflow and scoped token only. |
| CI/deploy failure | Failed job step, Helm history/events, rollout status | Fix tests/chart or restore previous chart revision with documented rollback script. |
| Kind control plane stalls | `kubectl get --raw=/readyz?verbose`, `docker stats platformops-control-plane`, `docker exec platformops-control-plane journalctl -u kubelet`, etcd logs | In this run etcd reported slow `fdatasync` and linearizable reads taking seconds, followed by API timeouts and controller-manager/scheduler CrashLoopBackOff. Stop only the dedicated node if it consumes excessive host resources, preserve it for diagnosis, and resume only after host load is understood. Do not delete or recreate it automatically. |

Only some symptoms can be observed without a working Docker daemon and Kind cluster. No failure scenario is marked completed until observed and recovered on an isolated runtime.
