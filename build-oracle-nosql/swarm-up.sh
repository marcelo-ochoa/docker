#!/bin/bash
docker-machine start manager1
docker-machine start manager2
docker-machine start worker1
docker-machine start worker2
eval $(docker-machine env manager1)

docker service create --network nosql_cluster --name master --replicas=1 -p 5001:5001 --env NODE_TYPE=m oracle-nosql/net

export MASTER_NODE_HOST=$(docker service ps master|grep master.1|grep Running|awk '{print $4}')
export MASTER_NODE_NAME=$(docker service ps master|grep master.1|grep Running|awk '{print $2"."$1}')
export MASTER_IP=$(docker-machine ssh $MASTER_NODE_HOST docker inspect --format='{{.NetworkSettings.Networks.nosql_cluster.IPAddress}}' $MASTER_NODE_NAME)


sleep 60

docker service create --network nosql_cluster --name slave --replicas=1 --env NODE_TYPE=s --env MASTER_NODE=$MASTER_IP oracle-nosql/net

sleep 60

docker service scale slave=2
