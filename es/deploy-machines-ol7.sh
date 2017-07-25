#!/bin/bash
# Sample call  sh ./deploy-machines.sh /home/mochoa/Documents/Scotas/ubnt

set -e
echo ""
echo "-------------------------------------"
echo "Deploying docker-machine for nodes..."
echo "-------------------------------------"
PRIV_SSH_KEY=$1

for i in $(awk '{print $1}' cloud.hosts); do
  echo "Creating $i docker-machine ...";
  IP_ADDR=$(grep $i cloud.hosts|awk '{print $2}');
  docker-machine create \
  --driver generic \
  --generic-ip-address=$IP_ADDR \
  --generic-ssh-key $PRIV_SSH_KEY \
  --generic-ssh-user opc $i || \
  echo "DOCKER_NETWORK_OPTIONS=-H tcp://0.0.0.0:2376 -H unix:///var/run/docker.sock --tlsverify --tlscacert /etc/docker/ca.pem --tlscert /etc/docker/server.pem --tlskey /etc/docker/server-key.pem --label provider=generic" | ssh -i $PRIV_SSH_KEY opc@$IP_ADDR sudo -s tee -a /etc/sysconfig/docker-network;
  ssh -i $PRIV_SSH_KEY opc@$IP_ADDR sudo -s systemctl restart docker;
done;

echo ""
echo "-------------------------------------------"
echo "docker-machine definitions ready to use ..."
echo "-------------------------------------------"

