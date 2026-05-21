#!/bin/bash
# build-docker.sh — Build mLITE dengan Docker
# Usage: ./scripts/build-docker.sh

set -e
echo "=== mLITE Docker Build ==="
cd "$(dirname "$0")/.."

command -v docker >/dev/null 2>&1 || { echo "Docker not installed"; exit 1; }

cp -n .env.example .env 2>/dev/null || true

docker compose build --no-cache 2>&1 | tee evidence/docker-build-log.txt

echo ""
echo "=== Build Selesai ==="
echo "Jalankan: docker compose up -d"
echo "Akses: http://localhost:8088"
echo "Log: evidence/docker-build-log.txt"
