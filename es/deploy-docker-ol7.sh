#!/bin/bash
# Sample call  sh ./deploy-docker.sh /home/mochoa/Documents/Scotas/ubnt

set -e
echo ""
echo "----------------------------"
echo "Deploying Docker to nodes..."
echo "----------------------------"
PRIV_SSH_KEY=$1

for i in $(awk '{print $1}' cloud.hosts); do
  echo "";
  echo "Deploying $i node with docker software ...";
  IP_ADDR=$(grep $i cloud.hosts|awk '{print $2}');
  ssh-keygen -f ~/.ssh/known_hosts -R $IP_ADDR;
  ssh -i $PRIV_SSH_KEY -o "StrictHostKeyChecking no" opc@$IP_ADDR curl https://raw.githubusercontent.com/marcelo-ochoa/docker/master/es/ol7-cloud-node-conf.sh -o /home/opc/ol7-cloud-node-conf.sh;
  ssh -i $PRIV_SSH_KEY opc@$IP_ADDR sudo -s sh ol7-cloud-node-conf.sh;
  ssh -i $PRIV_SSH_KEY opc@$IP_ADDR sudo shutdown -r +1;
done;

echo ""
echo "------------------------------"
echo "Wait until reboot last node..."
echo "------------------------------"
