#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="$ROOT_DIR/.tools/bin:$PATH"
original_context="$(kubectl config current-context 2>/dev/null || true)"
restore_context() {
  if [[ -n "$original_context" && "$original_context" != "kind-platformops" ]]; then
    kubectl config use-context "$original_context" >/dev/null || {
      echo "WARNING: could not restore previous kubectl context $original_context" >&2
    }
  fi
}
trap restore_context EXIT
command -v kind >/dev/null || { echo "kind is required" >&2; exit 127; }
if kind get clusters | grep -Fxq platformops; then
  echo "Kind cluster platformops already exists; checking the API without changing it."
else
  kind create cluster --name platformops --config "$ROOT_DIR/kubernetes/kind/cluster-config.yaml" --wait 5m
fi
kubectl --context kind-platformops wait --for=condition=Ready node/platformops-control-plane --timeout=180s
kubectl --request-timeout=20s --context kind-platformops get --raw=/readyz >/dev/null
echo "Kind cluster platformops API and node are ready."
