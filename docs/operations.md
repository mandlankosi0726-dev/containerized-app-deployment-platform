# Operations

## Local application and container

Use `make run` for loopback-only development. Use `make compose-up` for the image-backed local service. Check `/health`, `/ready` and `/metrics`. Inspect `docker ps`, `docker inspect`, `docker logs -f`, `docker exec <container> id`, `docker stats`, and host resource state with `ps`, `top`, `free -h`, `df -h`, `ss -tulpn`, `ip addr`, and `ip route`.

## Kubernetes

The provided scripts always target `kind-platformops`; inspect `kubectl config get-contexts` and `kind get clusters` before operations. `make status` reports Helm revision and resources. Follow logs with `kubectl --context kind-platformops -n platformops logs -f deploy/platformops`; inspect rollout with `kubectl rollout status` and history with `helm history platformops -n platformops`.

Scale temporarily with `kubectl --context kind-platformops -n platformops scale deployment/platformops --replicas=3`. A later Helm upgrade resets replica count to values unless HPA is enabled. For code updates build an immutable tag, load it to Kind, and run `scripts/deploy.sh <tag>`. To rollback inspect history then run `scripts/rollback.sh <revision>`. Validate health with a loopback `kubectl port-forward svc/platformops 8000:80` and HTTP requests. These workflows are documented; status is only marked validated after running against the dedicated cluster.

## Linux host diagnostics

Use `journalctl -u docker` and `systemctl status docker` when permitted, `docker info`, `ss -ltnp`, `dig`, `curl -v`, `df -h`, and `free -h`. Host firewall and SSH operations are intentionally not automated by this repository: changes can disrupt a developer workstation and are not required for a loopback-only Kind environment. Never run broad cleanup such as `docker system prune` as part of project teardown.
