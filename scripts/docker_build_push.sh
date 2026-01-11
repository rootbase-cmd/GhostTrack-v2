#!/usr/bin/env bash
set -euo pipefail
# Replace registry and tags as needed
REGISTRY=${1:-ghcr.io/yourorg}
TAG=${2:-latest}
docker build -f docker/Dockerfile.api -t $REGISTRY/dr-highkali-api:$TAG .
docker build -f docker/Dockerfile.nginx -t $REGISTRY/dr-highkali-web:$TAG .
echo "Built images. Push them with docker push <image>."
