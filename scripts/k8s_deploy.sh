#!/usr/bin/env bash
set -euo pipefail
echo "Applying k8s manifests..."
kubectl apply -f k8s/rbac.yaml
kubectl apply -f k8s/deployment-api.yaml
kubectl apply -f k8s/service-api.yaml
kubectl apply -f k8s/deployment-web.yaml
kubectl apply -f k8s/service-web.yaml
kubectl apply -f k8s/ingress.yaml
echo "Manifests applied. Configure ingress controller and TLS separately."
