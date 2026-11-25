#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="$ROOT_DIR/.tools/bin:$PATH"
command -v kind >/dev/null || { echo "kind is required" >&2; exit 127; }
if ! kind get clusters | grep -Fxq platformops; then
  echo "Kind cluster platformops does not exist; nothing to remove."
  exit 0
fi
echo "This removes the dedicated Kind cluster named platformops and its cluster data."
read -r -p 'Type delete-platformops to continue: ' confirmation
[[ "$confirmation" == "delete-platformops" ]] || { echo "Cancelled."; exit 1; }
kind delete cluster --name platformops
