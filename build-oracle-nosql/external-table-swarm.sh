#!/bin/bash
eval $(docker-machine env manager1)
export MASTER_NODE_NAME=$(docker service ps master|grep master|awk '{print $2"."$1}')
export SLAVE1_NODE_NAME=$(docker service ps slave|grep slave.1|awk '{print $2"."$1}')
export SLAVE2_NODE_NAME=$(docker service ps slave|grep slave.2|awk '{print $2"."$1}')
export MASTER_NODE_HOST=$(docker service ps master|grep master|awk '{print $4}')
export JAVAC="javac -cp examples:lib/kvclient.jar "
export JAVAR="java -cp examples:lib/kvclient.jar "
eval $(docker-machine env $MASTER_NODE_HOST)

docker exec -ti $MASTER_NODE_NAME $JAVAC examples/externaltables/UserInfo.java
docker exec -ti $MASTER_NODE_NAME $JAVAC examples/externaltables/MyFormatter.java
docker exec -ti $MASTER_NODE_NAME $JAVAC examples/externaltables/LoadCookbookData.java
docker exec -ti $MASTER_NODE_NAME $JAVAR externaltables.LoadCookbookData -store mystore -host $MASTER_NODE_NAME -port 5000 -delete
