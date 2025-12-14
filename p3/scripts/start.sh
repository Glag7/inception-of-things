#!/bin/bash

echo "creating k3d cluster"
k3d cluster create iot

echo "creating namespaces"
kubectl create namespace argocd
kubectl create namespace dev

echo "installing argocd in 'argocd' namespace"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "waiting for argocd to be deployed"
kubectl wait --for=condition=available pods deployment/argocd-server -n argocd --timeout=300s

echo "=== argocd credentials ==="
echo "login: admin"
echo -n "password: "
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d) #password in is base64, decode it
echo "$ARGOCD_PASSWORD"
echo "$ARGOCD_PASSWORD" > pass.txt

echo "forwarding argocd ui port on 8080"
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

while ! nc -z localhost 8080; do   #while port inst forwarded wait
  sleep 1
done

echo "setting up argo"

#log in
argocd login localhost:8080 --username admin --password "$ARGOCD_PASSWORD" --insecure

#argo will monitor this repo
argocd repo add https://github.com/Glag7/inception-of-things-test-app-glaguyon.git
argocd app create wil-playground \
  --repo https://github.com/Glag7/inception-of-things-test-app-glaguyon.git \
  --path manifest/app \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace dev \
  --project default \
  --sync-policy automated
#argocd app create wil-playground \ #name in argocd ui
#  --repo https://github.com/Glag7/inception-of-things-test-app-glaguyon.git \ #repo to monitor
#  --path manifest/app \ #path in repo
#  --dest-server https://kubernetes.default.svc \ #use current cluster
#  --dest-namespace dev \ #deploy to dev namespace
#  --project default \ #simple config for demo
#  --sync-policy automated #auto sync

kubectl port-forward svc/wil-playground -n dev 8888:8888 2>&1 >/dev/null &
