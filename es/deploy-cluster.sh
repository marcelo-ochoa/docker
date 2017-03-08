# Network to interconnect ES cluster
docker network create -d overlay \
        --attachable \
	--subnet=192.168.0.0/24 \
	es_cluster

# Node afinity
docker node update --label-add type=es_master oc5
docker node update --label-add type=es_master oc4
docker node update --label-add type=es_data   oc3
docker node update --label-add type=es_data   oc2
docker node update --label-add type=es_ingest oc1


# Provisioning image with a modified config/elasticsearch.yml
eval $(docker-machine env oc5)
docker build -t "elasticsearch/swarm:5.0.0" .

eval $(docker-machine env oc4)
docker build -t "elasticsearch/swarm:5.0.0" .

eval $(docker-machine env oc3)
docker build -t "elasticsearch/swarm:5.0.0" .

eval $(docker-machine env oc2)
docker build -t "elasticsearch/swarm:5.0.0" .

eval $(docker-machine env oc1)
docker build -t "elasticsearch/swarm:5.0.0" .

eval $(docker-machine env oc5)

docker service create --network es_cluster --name es_master --constraint 'node.labels.type == es_master' --replicas=1 --publish 9200:9200/tcp --env ES_JAVA_OPTS="-Xms1g -Xmx1g"  "elasticsearch/swarm:5.0.0" -E cluster.name="ESCookBook" -E node.master=true -E node.data=false -E discovery.zen.ping.unicast.hosts=es_master
# Wait for master node up and running
sleep 60
export MASTER_NODE_HOST=$(docker service ps es_master|grep es_master.1|grep Running|awk '{print $4}')
export MASTER_NODE_ID=$(docker-machine ssh $MASTER_NODE_HOST docker ps|grep es_master.1|awk '{print $1}')
export ES_MASTER_IP=$(docker-machine ssh $MASTER_NODE_HOST docker exec $MASTER_NODE_ID cat /etc/hosts|tail -1|awk '{print $1}')

docker service create --network es_cluster --name es_data --constraint 'node.labels.type == es_data' --replicas=2 --env ES_JAVA_OPTS="-Xms1g -Xmx1g" "elasticsearch/swarm:5.0.0" -E cluster.name="ESCookBook" -E node.master=false -E node.data=true -E discovery.zen.ping.unicast.hosts=es_master

docker service create --network es_cluster --name es_ingest --constraint 'node.labels.type == es_ingest' --replicas=1 --env ES_JAVA_OPTS="-Xms1g -Xmx1g" "elasticsearch/swarm:5.0.0" -E cluster.name="ESCookBook" -E node.master=false -E node.data=false -E node.ingest=true -E discovery.zen.ping.unicast.hosts=es_master

# Wait for cluster startup
sleep 120
docker-machine ssh $MASTER_NODE_HOST curl http://localhost:9200/_nodes/process?pretty


