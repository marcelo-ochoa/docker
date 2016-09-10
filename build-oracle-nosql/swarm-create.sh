#!/usr/bin/env bash

# set -e

docker-machine create --driver virtualbox manager1
docker-machine create --driver virtualbox manager2
docker-machine create --driver virtualbox worker1
docker-machine create --driver virtualbox worker2
docker-machine stop $(docker-machine ls -q)

VBoxManage modifyvm "manager1" --natdnshostresolver1 on --memory 8192
VBoxManage modifyvm "manager2" --natdnshostresolver1 on --memory 8192
VBoxManage modifyvm "worker1" --natdnshostresolver1 on --memory 8192
VBoxManage modifyvm "worker2" --natdnshostresolver1 on --memory 8192

# Build Docker Swarm cluster
docker-machine start manager1
export MANAGER1_IP=$(docker-machine ip manager1)
docker-machine ssh manager1 docker swarm init --advertise-addr eth1
export MGR_TOKEN=$(docker-machine ssh manager1 docker swarm join-token manager -q)
export WRK_TOKEN=$(docker-machine ssh manager1 docker swarm join-token worker -q)


docker-machine start manager2
docker-machine ssh manager2 \
docker swarm join \
--token $MGR_TOKEN \
$MANAGER1_IP:2377

docker-machine start worker1
docker-machine ssh worker1 \
docker swarm join \
--token $WRK_TOKEN \
$MANAGER1_IP:2377

docker-machine start worker2
docker-machine ssh worker2 \
docker swarm join \
--token $WRK_TOKEN \
$MANAGER1_IP:2377

# Provisioning image
eval $(docker-machine env manager1)
docker build -t "oracle-nosql/net" .

eval $(docker-machine env manager2)
docker build -t "oracle-nosql/net" .

eval $(docker-machine env worker1)
docker build -t "oracle-nosql/net" .

eval $(docker-machine env worker2)
docker build -t "oracle-nosql/net" .

# Define network between nodes
eval $(docker-machine env manager1)

docker network create -d overlay nosql_cluster

# Define services
docker service create \
  --network nosql_cluster \
  --name nosql_master \
  --env NODE_TYPE=m \
  -p 5000:5000 \
  -p 5001:5001 \
  oracle-nosql/net

export MASTER_NODE_NAME=$(docker service ps nosql_master|grep nosql_master.1|grep Running|awk '{print $2"."$1}')

docker service create \
  --network nosql_cluster \
  --name nosql_slave \
  --replicas 2 \
  --env NODE_TYPE=s \
  --env MASTER_NODE_NAME=$MASTER_NODE_NAME \
  oracle-nosql/net

