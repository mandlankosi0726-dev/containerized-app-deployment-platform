#!/usr/bin/env bash
set -euo pipefail

context=kind-platformops
namespace=platformops
local_port=18081
command -v kubectl >/dev/null || { echo "kubectl is required" >&2; exit 127; }
kubectl --context "$context" -n "$namespace" rollout status deployment/platformops --timeout=180s
kubectl --context "$context" -n "$namespace" port-forward --address 127.0.0.1 \
  "service/platformops" "$local_port:80" >/dev/null 2>&1 &
forward_pid=$!
cleanup() {
  kill "$forward_pid" >/dev/null 2>&1 || true
  wait "$forward_pid" >/dev/null 2>&1 || true
}
trap cleanup EXIT

base_url="http://127.0.0.1:$local_port"
for attempt in $(seq 1 60); do
  if curl --fail --silent --max-time 2 "$base_url/health" >/dev/null; then break; fi
  if [[ "$attempt" == 60 ]]; then
    kubectl --context "$context" -n "$namespace" get pods,services,endpoints
    exit 1
  fi
  sleep 1
done

for endpoint in health live ready api/v1/info api/v1/system; do
  curl --fail --silent "$base_url/$endpoint" >/dev/null
  echo "PASS Kubernetes GET /$endpoint"
done
curl --fail --silent "$base_url/metrics" | grep -q 'platformops_http_requests_total'
echo "PASS Kubernetes GET /metrics"
kubectl --context "$context" -n "$namespace" get deployment,pods,service,endpoints
