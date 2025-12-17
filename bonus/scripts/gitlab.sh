#!/bin/bash

GITLAB_HOST="gitlab.k3d.local:8081"

# get password
GITLAB_PASSWORD=$(kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 -d)

# file used for auto login features
echo "machine gitlab.k3d.local
login root
password ${GITLAB_PASSWORD}" > ~/.netrc
chmod 600 ~/.netrc

# clone the gitlab repo (CREATE IT FIRST)
git clone http://${GITLAB_HOST}/root/test.git gitlab_repo || {
    echo "Failed to clone from GitLab. Make sure:"
    echo "1. GitLab is running (check with: kubectl get pods -n gitlab)"
    echo "2. Repository 'test' exists in GitLab"
    echo "3. Port forwarding is active (check with: ps aux | grep port-forward)"
    exit 1
}

git clone https://github.com/Glag7/inception-of-things-test-app-glaguyon.git github_repo

mv github_repo/manifest gitlab_repo/
sed -i 's/name: playground-service/name: playground-service2/g' gitlab_repo/manifest/app/wil.yaml
sed -i 's/name: playground-app/name: playground-app2/g' gitlab_repo/manifest/app/wil.yaml
sed -i 's/app: playground-app/app: playground-app2/g' gitlab_repo/manifest/app/wil.yaml

rm -rf github_repo/

cd gitlab_repo
git config --global user.email "root@root.com"
git config --global user.name "root"

git add .
git commit -m "test gitlab"
git push
# content of github repo is in gitlab

cd ..

# the internal service runs on port 8181 (not 8081)
argocd app create wil-playground2 \
  --repo http://gitlab-webservice-default.gitlab.svc:8181/root/test.git \
  --path manifest/app \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace dev \
  --project default \
  --sync-policy automated

echo "Waiting for wil-playground2 service to be created..."
sleep 30

kubectl port-forward svc/playground-service2 8889:8888 -n dev 2>&1 >/dev/null &
