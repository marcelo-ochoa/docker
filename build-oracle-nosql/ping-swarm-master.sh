#!/bin/bash
export CONSUL_IP=$(docker-machine ip proxy)
export PROXY_IP=$(docker-machine ip proxy)
export DOCKER_IP=$(docker-machine ip swarm-master)
eval $(docker-machine env --swarm swarm-master)

docker exec $(docker ps|grep oracle-nosql|grep nosql_master|cut -d " " -f1) java -jar /kv-3.5.2/lib/kvstore.jar ping -host nosql_master_1 -port 5000
