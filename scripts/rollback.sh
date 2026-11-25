#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="$ROOT_DIR/.tools/bin:$PATH"
revision="${1:-}"
if [[ -z "$revision" || ! "$revision" =~ ^[1-9][0-9]*$ ]]; then
  echo "Usage: $0 <helm-revision-number>" >&2
  echo "Inspect revisions with: helm history platformops --namespace platformops --kube-context kind-platformops" >&2
  exit 2
fi
helm rollback platformops "$revision" --kube-context kind-platformops --namespace platformops --wait --timeout 180s
kubectl --context kind-platformops -n platformops rollout status deployment/platformops --timeout=180s
