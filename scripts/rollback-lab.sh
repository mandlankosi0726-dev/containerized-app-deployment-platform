#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="$ROOT_DIR/.tools/bin:$PATH"
context=kind-platformops
namespace=platformops
good_tag="${1:-v0.1.0}"

helm upgrade --install platformops "$ROOT_DIR/helm/platformops" \
  --kube-context "$context" --namespace "$namespace" \
  --values "$ROOT_DIR/helm/platformops/values-development.yaml" \
  --set-string image.tag="$good_tag" \
  --set-string config.buildRevision=rollback-baseline \
  --wait --timeout 180s
baseline_revision="$(helm --kube-context "$context" -n "$namespace" history platformops --output json \
  | python3 -c 'import json,sys; print(max(int(item["revision"]) for item in json.load(sys.stdin) if item["status"] == "deployed"))')"
echo "Known-good revision: $baseline_revision"

if helm upgrade platformops "$ROOT_DIR/helm/platformops" \
  --kube-context "$context" --namespace "$namespace" \
  --values "$ROOT_DIR/helm/platformops/values-development.yaml" \
  --set-string image.tag=platformops-failure-probe \
  --wait --timeout 60s; then
  echo "Expected broken image rollout to fail, but Helm reported success." >&2
  exit 1
else
  echo "Observed expected failed rollout for image tag platformops-failure-probe."
fi

helm --kube-context "$context" -n "$namespace" history platformops
kubectl --context "$context" -n "$namespace" get pods
helm rollback platformops "$baseline_revision" \
  --kube-context "$context" --namespace "$namespace" --wait --timeout 180s
kubectl --context "$context" -n "$namespace" rollout status deployment/platformops --timeout=180s
kubectl --context "$context" -n "$namespace" get deployment,pods,service,endpoints
