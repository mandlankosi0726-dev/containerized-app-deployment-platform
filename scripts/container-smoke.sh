#!/usr/bin/env bash
set -euo pipefail

image="${1:-platformops-deployment-platform:v0.1.0}"
name="platformops-deployment-platform-smoke-$$"
container_id=""
cleanup() {
  if [[ -n "$container_id" ]]; then
    docker rm -f "$container_id" >/dev/null
  fi
}
trap cleanup EXIT

if docker container inspect "$name" >/dev/null 2>&1; then
  echo "Refusing to touch pre-existing container $name" >&2
  exit 1
fi
container_id="$(docker run -d --name "$name" \
  --publish 127.0.0.1::8000 \
  --read-only --tmpfs /tmp:size=16m,noexec,nosuid,nodev \
  --cap-drop ALL --security-opt no-new-privileges \
  "$image")"
published_port="$(docker port "$container_id" 8000/tcp | sed 's/.*://')"
base_url="http://127.0.0.1:$published_port"

wait_healthy() {
  for attempt in $(seq 1 30); do
    health="$(docker inspect "$container_id" --format '{{.State.Health.Status}}')"
    if [[ "$health" == "healthy" ]]; then return 0; fi
    if [[ "$health" == "unhealthy" || "$attempt" == 30 ]]; then
      docker inspect "$container_id" --format '{{json .State.Health}}'
      return 1
    fi
    sleep 1
  done
}

for attempt in $(seq 1 30); do
  if curl --fail --silent "$base_url/ready" >/dev/null; then break; fi
  if [[ "$attempt" == 30 ]]; then docker logs "$container_id"; exit 1; fi
  sleep 1
done
wait_healthy

echo "Container user and health:"
docker inspect "$container_id" --format 'user={{.Config.User}} health={{.State.Health.Status}}'
[[ "$(docker inspect "$container_id" --format '{{.Config.User}}')" == "10001:10001" ]]
curl --fail --silent "$base_url/"; echo
for endpoint in health live ready api/v1/info api/v1/system; do
  curl --fail --silent "$base_url/$endpoint" >/dev/null
  echo "PASS GET /$endpoint"
done
curl --fail --silent "$base_url/health" >/dev/null
curl --fail --silent "$base_url/metrics" | grep -q 'platformops_http_requests_total'
echo "PASS GET /metrics (Prometheus request metric found)"
echo "Resource usage:"
docker stats --no-stream "$container_id" --format 'cpu={{.CPUPerc}} memory={{.MemUsage}}'
echo "Recent logs:"
docker logs "$container_id" 2>&1 | tail -5

docker restart "$container_id" >/dev/null
published_port="$(docker port "$container_id" 8000/tcp | sed 's/.*://')"
base_url="http://127.0.0.1:$published_port"
for attempt in $(seq 1 30); do
  if curl --fail --silent "$base_url/health" >/dev/null; then break; fi
  if [[ "$attempt" == 30 ]]; then docker logs "$container_id"; exit 1; fi
  sleep 1
done
wait_healthy
echo "PASS restart and health check"
docker stop --time 10 "$container_id" >/dev/null
echo "PASS graceful stop; exit_code=$(docker inspect "$container_id" --format '{{.State.ExitCode}}')"

# The EXIT trap removes only the container ID created by this run. The image remains.
