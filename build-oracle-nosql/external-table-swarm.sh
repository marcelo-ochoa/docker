#!/bin/bash
export CONSUL_IP=$(docker-machine ip proxy)
export PROXY_IP=$(docker-machine ip proxy)
export DOCKER_IP=$(docker-machine ip swarm-master)
eval $(docker-machine env --swarm swarm-master)

docker exec -t $(docker ps|grep oracle-nosql|grep nosql_master|cut -d " " -f1) javac -cp examples:lib/kvclient.jar examples/externaltables/UserInfo.java
docker exec -t $(docker ps|grep oracle-nosql|grep nosql_master|cut -d " " -f1) javac -cp examples:lib/kvclient.jar examples/externaltables/MyFormatter.java
docker exec -t $(docker ps|grep oracle-nosql|grep nosql_master|cut -d " " -f1) javac -cp examples:lib/kvclient.jar examples/externaltables/LoadCookbookData.java
docker exec -t $(docker ps|grep oracle-nosql|grep nosql_master|cut -d " " -f1) java -cp examples:lib/kvclient.jar externaltables.LoadCookbookData -store mystore -host nosql_slave_1 -port 5000 -delete
