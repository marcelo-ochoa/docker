#!/bin/bash
eval $(docker-machine env manager1)
export MASTER_NODE_HOST=$(docker service ps nosql_master|grep nosql_master.1|grep Running|awk '{print $4}')
export MASTER_NODE_NAME=$(docker service ps nosql_master|grep nosql_master.1|grep Running|awk '{print $2"."$1}')
export NS1_HOSTNAME=$(docker-machine ssh $MASTER_NODE_HOST docker inspect --format='{{.Config.Hostname}}' $MASTER_NODE_NAME)
eval $(docker-machine env $MASTER_NODE_HOST)

docker exec -t $MASTER_NODE_NAME javac -cp examples:lib/kvclient.jar examples/hello/HelloBigDataWorld.java
docker exec -t $MASTER_NODE_NAME java -cp examples:lib/kvclient.jar hello.HelloBigDataWorld -store mystore -host $MASTER_NODE_NAME -port 5000
