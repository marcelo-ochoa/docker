#!/bin/bash
eval $(docker-machine env manager1)
export MASTER_NODE_HOST=$(docker service ps nosql_master|grep nosql_master.1|grep Running|awk '{print $4}')
export MASTER_NODE_NAME=$(docker service ps nosql_master|grep nosql_master.1|grep Running|awk '{print $2"."$1}')
export NS1_HOSTNAME=$(docker-machine ssh $MASTER_NODE_HOST docker inspect --format='{{.Config.Hostname}}' $MASTER_NODE_NAME)
export SLAVE1_NODE_HOST=$(docker service ps nosql_slave|grep nosql_slave.1|grep Running|awk '{print $4}')
export SLAVE1_NODE_NAME=$(docker service ps nosql_slave|grep nosql_slave.1|grep Running|awk '{print $2"."$1}')
export NS2_HOSTNAME=$(docker-machine ssh $SLAVE1_NODE_HOST docker inspect --format='{{.Config.Hostname}}' $SLAVE1_NODE_NAME)
export SLAVE2_NODE_HOST=$(docker service ps nosql_slave|grep nosql_slave.2|grep Running|awk '{print $4}')
export SLAVE2_NODE_NAME=$(docker service ps nosql_slave|grep nosql_slave.2|grep Running|awk '{print $2"."$1}')
export NS3_HOSTNAME=$(docker-machine ssh $SLAVE2_NODE_HOST docker inspect --format='{{.Config.Hostname}}' $SLAVE2_NODE_NAME)
export CMD_LINE="java -jar /kv-4.0.9/lib/kvstore.jar runadmin -host $NS1_HOSTNAME -port 5000 "
eval $(docker-machine env $MASTER_NODE_HOST)

docker exec -ti $MASTER_NODE_NAME $CMD_LINE configure -name mystore
docker exec -ti $MASTER_NODE_NAME $CMD_LINE plan deploy-zone -name "Tandil" -name MyZone -rf 3 -wait

docker exec -ti $MASTER_NODE_NAME $CMD_LINE plan deploy-sn -znname MyZone -host $NS1_HOSTNAME -port 5000 -wait
docker exec -ti $MASTER_NODE_NAME $CMD_LINE plan deploy-admin -sn sn1 -port 5001 -wait
docker exec -ti $MASTER_NODE_NAME $CMD_LINE pool create -name MyPool
docker exec -ti $MASTER_NODE_NAME $CMD_LINE pool join -name MyPool -sn sn1

docker exec -ti $MASTER_NODE_NAME $CMD_LINE plan deploy-sn -znname MyZone -host $NS2_HOSTNAME -port 5000 -wait
docker exec -ti $MASTER_NODE_NAME $CMD_LINE pool join -name MyPool -sn sn2

docker exec -ti $MASTER_NODE_NAME $CMD_LINE plan deploy-sn -znname MyZone -host $NS3_HOSTNAME -port 5000 -wait
docker exec -ti $MASTER_NODE_NAME $CMD_LINE pool join -name MyPool -sn sn3

docker exec -ti $MASTER_NODE_NAME $CMD_LINE topology create -name MyStoreLayout -pool MyPool -partitions 100
docker exec -ti $MASTER_NODE_NAME $CMD_LINE plan deploy-topology -name MyStoreLayout -wait
docker exec -ti $MASTER_NODE_NAME $CMD_LINE show plans
docker exec -ti $MASTER_NODE_NAME $CMD_LINE show topology
docker exec -ti $MASTER_NODE_NAME $CMD_LINE verify configuration

docker exec -ti $MASTER_NODE_NAME java -jar /kv-4.0.9/lib/kvstore.jar ping -host $NS1_HOSTNAME -port 5000
