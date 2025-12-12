#!/bin/bash

echo "=== Installing Docker ==="

# install prerequisites
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl

# add docker's gpg key
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# add docker apt repo
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# install docker packages
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# start docker
sudo systemctl --now enable docker

#add user to docker group
sudo usermod -aG docker "$USER"

#===============================

echo "=== Installing kubectl ==="

# download it
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# install to system path
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

#rm downloaded file
rm kubectl

#======================================

echo "=== Installing k3d ==="

# download k3d installer script
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | TAG=v5.7.3 bash
