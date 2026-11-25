#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tag="${1:-}"
if [[ -z "$tag" || ! "$tag" =~ ^([0-9a-f]{7,40}|v?[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9.-]+)?)$ ]]; then
  echo "Usage: $0 <git-sha-or-semver-tag>" >&2
  exit 2
fi
command -v docker >/dev/null || { echo "docker is required" >&2; exit 127; }
docker build -t "platformops-deployment-platform:$tag" "$ROOT_DIR/app"
docker image inspect "platformops-deployment-platform:$tag" --format 'image={{.Id}} user={{.Config.User}} size={{.Size}}'
