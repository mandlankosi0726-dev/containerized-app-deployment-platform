#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="$ROOT_DIR/.tools/bin:$PATH"
tag="${1:-}"
if [[ -z "$tag" || ! "$tag" =~ ^([0-9a-f]{7,40}|v?[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9.-]+)?)$ ]]; then
  echo "Usage: $0 <immutable-image-tag> (dev/latest are not accepted)" >&2
  exit 2
fi
for bin in kind kubectl helm; do command -v "$bin" >/dev/null || { echo "$bin is required" >&2; exit 127; }; done
kind get clusters | grep -Fxq platformops || { echo "Dedicated Kind cluster platformops does not exist" >&2; exit 1; }
context=kind-platformops
kubectl --context "$context" cluster-info >/dev/null
docker image inspect "platformops-deployment-platform:$tag" >/dev/null
kind load docker-image "platformops-deployment-platform:$tag" --name platformops
helm upgrade --install platformops "$ROOT_DIR/helm/platformops" \
  --kube-context "$context" --namespace platformops --create-namespace \
  --values "$ROOT_DIR/helm/platformops/values-development.yaml" \
  --set-string image.tag="$tag" --wait --timeout 180s
kubectl --context "$context" -n platformops rollout status deployment/platformops --timeout=180s
