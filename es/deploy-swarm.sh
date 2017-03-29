#!/bin/bash
# Sample call  sh ./deploy-swarm.sh oc5

set -e
echo ""
echo "----------------------------"
echo "Deploying swarm for nodes..."
echo "----------------------------"
SWARM_MANAGER=$1

docker-machine ssh $SWARM_MANAGER docker swarm init --advertise-addr eth0

JOIN_TOKEN=$(docker-machine ssh $SWARM_MANAGER docker swarm join-token worker -q)
MGR_HOST_PORT=$(docker-machine ssh $SWARM_MANAGER docker swarm join-token worker | tail -2)

for i in $(awk '{print $1}' cloud.hosts); do
  if [ "$i" != "$SWARM_MANAGER" ]; then
    echo "Joining $i to swarm cluster ...";
    docker-machine ssh $i docker swarm join --token $JOIN_TOKEN $MGR_HOST_PORT;
  fi;
done;
eval $(docker-machine env $SWARM_MANAGER)
docker node ls

echo ""
echo "----------------------"
echo "Swarm ready to use ..."
echo "----------------------"

