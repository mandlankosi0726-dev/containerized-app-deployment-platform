# Deployment lifecycle

1. Install Python, Docker Engine/Compose, kubectl, Kind, Helm and Trivy.
   Locally downloaded checksum-verified Kind and Helm tools are kept under ignored `.tools/bin`; add it to `PATH` with `export PATH="$PWD/.tools/bin:$PATH"` when using the terminal directly. Project scripts prepend this directory automatically.
2. Create/activate a Python virtual environment; install `app/requirements-dev.lock` and editable package metadata.
3. Run `make app-check` and `make validate`.
4. Build an image tag based on a Git SHA or release version: `scripts/build-image.sh <tag>`.
5. Start local Compose with `make compose-up` and inspect health/logs.
6. Create the dedicated local cluster using `make kind-create`. It does not use or replace the current context.
7. Deploy with `scripts/deploy.sh <tag>`; the script loads the image into Kind, upgrades the Helm release and waits for rollout.
8. Inspect with `make status`; access using `kubectl --context kind-platformops -n platformops port-forward svc/platformops 8000:80`.
9. Scale with `kubectl --context kind-platformops -n platformops scale deployment/platformops --replicas=3`.
10. Build/load a different immutable tag and rerun deployment for a rolling update.
11. Inspect `helm history`, select a prior revision, and run `scripts/rollback.sh <revision>`.
12. Stop port-forward and Compose. Delete only the named project Kind cluster via `make kind-delete`; the command asks for typed confirmation and removes that cluster's data.

No AWS resources or production cluster are part of this flow.
