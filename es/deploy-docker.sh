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
  ssh -i $PRIV_SSH_KEY -o "StrictHostKeyChecking no" ubuntu@$IP_ADDR wget https://raw.githubusercontent.com/marcelo-ochoa/docker/master/es/oracle-cloud-node-conf.sh;
  ssh -i $PRIV_SSH_KEY ubuntu@$IP_ADDR sudo -s sh oracle-cloud-node-conf.sh;
  ssh -i $PRIV_SSH_KEY ubuntu@$IP_ADDR sudo shutdown -r +1;
done;

echo ""
echo "------------------------------"
echo "Wait until reboot last node..."
echo "------------------------------"

