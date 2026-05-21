#!/bin/bash
# build-podman.sh — Build mLITE dengan Podman
# Usage: ./scripts/build-podman.sh

set -e
echo "=== mLITE Podman Build ==="
cd "$(dirname "$0")/.."

command -v podman >/dev/null 2>&1 || { echo "Podman not installed"; exit 1; }

cp -n .env.example .env 2>/dev/null || true

podman build -t mlite-php:latest -f Containerfile . 2>&1 | tee evidence/podman-build-log.txt

echo ""
echo "=== Build Selesai ==="
echo "Jalankan: podman-compose up -d"
echo "Log: evidence/podman-build-log.txt"
