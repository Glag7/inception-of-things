#!/bin/bash

echo "=== setting up gitLab ==="

# add gitLab to hosts
HENTRY="127.0.0.1 gitlab.k3d.local"
HFILE="/etc/hosts"

if grep -q "$HENTRY" "$HFILE"; then
else
    echo "Adding $HENTRY to $HFILE"
    echo "$HENTRY" | sudo tee -a "$HFILE"
fi

echo "creating namespace gitlab"
kubectl create namespace gitlab 2>/dev/null

echo "installing gitlab via helm"
helm repo add gitlab https://charts.gitlab.io/
helm repo update

helm upgrade --install gitlab gitlab/gitlab \
  -n gitlab \
  -f https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml \
  --set global.hosts.domain=k3d.local \
  --set global.hosts.externalIP=0.0.0.0 \
  --set global.hosts.https=false \
  --timeout 600s

echo "waiting for gitlab"
kubectl wait --for=condition=ready --timeout=600s pod -l app=webservice -n gitlab

# get gitlab password
echo "url: http://gitlab.k3d.local"
echo "login: root"
echo -n "Password: "
kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -ojsonpath="{.data.password}" | base64 -d
echo ""

echo "starting port forwarding for gitlab (http://localhost:8081)"
kubectl port-forward svc/gitlab-webservice-default 8081:8181 -n gitlab 2>&1 >/dev/null &
GPID=$!

