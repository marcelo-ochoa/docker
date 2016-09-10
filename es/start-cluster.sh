#!/bin/bash

docker service create --network es_cluster --name es_master --constraint 'node.labels.type == es_master' --replicas=1 -p 9200:9200 -p 9300:9300 --env ES_JAVA_OPTS="-Xms1g -Xmx1g"  elasticsearch/swarm:5.0.0 -E bootstrap.ignore_system_bootstrap_checks=true -E cluster.name="ESCookBook" -E node.master=true -E node.data=false -E discovery.zen.ping.unicast.hosts=es_master

sleep 60

docker service create --network es_cluster --name es_data --constraint 'node.labels.type == es_data' --replicas=2 --env ES_JAVA_OPTS="-Xms1g -Xmx1g" elasticsearch/swarm:5.0.0 -E bootstrap.ignore_system_bootstrap_checks=true -E cluster.name="ESCookBook" -E node.master=false -E node.data=true -E discovery.zen.ping.unicast.hosts=es_master

sleep 60

docker service create --network es_cluster --name es_ingest --constraint 'node.labels.type == es_ingest' --replicas=1 --env ES_JAVA_OPTS="-Xms1g -Xmx1g" elasticsearch/swarm:5.0.0 -E bootstrap.ignore_system_bootstrap_checks=true -E cluster.name="ESCookBook" -E node.master=false -E node.data=false -E node.ingest=true -E discovery.zen.ping.unicast.hosts=es_master

# Wait for cluster startup
sleep 60
curl http://192.168.99.100:9200/_nodes/process?pretty

