#!/bin/bash

#get passwd
GITLAB_PASSWORD=$(sudo kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 -d)

#file used for auto login features
echo "machine gitlab.k3d.gitlab.com
login root
password ${GITLAB_PASSWORD}"> ~/.netrc
sudo chmod 600 ~/.netrc

#clone the gitlab repo
git clone http://gitlab.k3d.local/root/test.git gitlab_repo
git clone https://github.com/Glag7/inception-of-things-test-app-glaguyon.git github_repo

mv github_repo/manifest gitlab_repo/
rm -rf github_repo/

cd gitlab_repo

git config --global user.email "root@root.com"
git config --global user.name "root"

git add .
git commit -m "test gitlab"
git push
#content of github repo si in gitlab

cd ..

#same as before
argocd app create wil-playground2 \
  --repo http://gitlab-webservice-default.gitlab.svc:8181/root/test.git \
  --path manifest/app \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace dev \
  --project default \
  --sync-policy automated

kubectl port-forward svc/wil-playground2 8888:8888 -n dev 2>&1 >/dev/null &
