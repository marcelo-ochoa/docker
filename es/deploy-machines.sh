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
  --generic-ssh-user ubuntu $i;
done;

echo ""
echo "-------------------------------------------"
echo "docker-machine definitions ready to use ..."
echo "-------------------------------------------"

