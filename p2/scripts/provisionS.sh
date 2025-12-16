curl -sfL https://get.k3s.io | sh -s - --node-ip=192.168.56.110 #use the vm private network
sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/node-token #create token for workers
sudo ip link add eth1 type dummy && sudo ip addr add 192.168.56.110/24 dev eth1 && sudo ip link set eth1 up #safeguard for apps that use eth1

#deploy + service
kubectl apply -f /vagrant/confs/app1.yaml
kubectl apply -f /vagrant/confs/app2.yaml
kubectl apply -f /vagrant/confs/app3.yaml

#ingress (creates domain names)
kubectl apply -f /vagrant/confs/appingress.yaml
