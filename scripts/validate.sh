#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="$ROOT_DIR/.tools/bin:$PATH"
cd "$ROOT_DIR"
echo "Validating Kustomize manifests..."
kubectl kustomize kubernetes/overlays/development >/dev/null
if command -v helm >/dev/null 2>&1; then
  helm lint helm/platformops --values helm/platformops/values-development.yaml
  helm template platformops helm/platformops --namespace platformops \
    --values helm/platformops/values-development.yaml --set-string image.tag=validation >/dev/null
else
  echo "SKIP: helm unavailable; chart lint/render not validated."
fi
if docker compose version >/dev/null 2>&1; then
  docker compose -f docker/compose.yaml config >/dev/null
else
  echo "SKIP: Docker Compose plugin unavailable."
fi
if command -v trivy >/dev/null 2>&1; then
  for target in kubernetes helm docker app/Dockerfile; do
    trivy config --skip-check-update --skip-version-check --exit-code 1 --severity HIGH,CRITICAL "$target"
  done
else
  echo "SKIP: trivy unavailable."
fi
