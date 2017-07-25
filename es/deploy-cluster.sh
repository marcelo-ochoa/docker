#!/bin/bash
# Sample call  sh ./deploy-cluster.sh node5
# Provisioning image with a modified config/elasticsearch.yml
echo ""
echo "----------------------------"
echo "Deploying swarm for nodes..."
echo "----------------------------"
SWARM_MANAGER=$1

echo ""
echo "-----------------------------------------"
echo "Building private ES image on all nodes..."
echo "-----------------------------------------"

for i in $(awk '{print $1}' cloud.hosts); do
  echo "Building ES at $i node ...";
  eval $(docker-machine env $i);
  docker build -t "elasticsearch/swarm:5.0.0" .;
done;

eval $(docker-machine env $SWARM_MANAGER)
echo ""
echo "-------------------------------------"
echo "Setting node afinity for all nodes..."
echo "-------------------------------------"
for i in $(awk '{print $1}' cloud.hosts); do
  AFNTY=$(grep $i cloud.hosts|awk '{print $3}');
  echo "Setting $AFNTY for $i node ...";
  docker node update --label-add type=$AFNTY $i;
done;


# Network to interconnect ES cluster
docker network create -d overlay \
        --attachable \
	--subnet=192.168.0.0/24 \
	es_cluster
echo ""
echo "--------------------------------------------------"
echo "Running Swarm visualizer at $SWARM_MANAGER node..."
echo "--------------------------------------------------"
# internal IP 192.168.0.2
docker run -d \
   --name viz \
   -p 8080:8080 \
   --net es_cluster \
   -v /var/run/docker.sock:/var/run/docker.sock dockersamples/visualizer:latest

echo ""
echo "-----------------------------------------------------------------"
echo "Running Cerebro to visualize ES cluster at $SWARM_MANAGER node..."
echo "-----------------------------------------------------------------"
# internal IP 192.168.0.3
docker run -d  \
  -p 8000:9000 \
  --net es_cluster \
  --env JAVA_OPTS="-Djava.net.preferIPv4Stack=true" \
  --name cerebro yannart/cerebro:latest

echo ""
echo "--------------------------------"
echo "Deploying ES cluster to Swarm..."
echo "--------------------------------"
# internal IP 192.168.0.5,  es_master=192.168.0.4
docker service create --network es_cluster --name es_master --constraint 'node.labels.type == es_master' --replicas=1 --publish 9200:9200/tcp --env ES_JAVA_OPTS="-Xms1g -Xmx1g" elasticsearch/swarm:5.0.0 -E cluster.name="ESCookBook" -E node.master=true -E node.data=false -E discovery.zen.ping.unicast.hosts=192.168.0.5
# Wait for master node up and running
sleep 60

docker service create --network es_cluster --name es_data --constraint 'node.labels.type == es_data' --replicas=2 --env ES_JAVA_OPTS="-Xms1g -Xmx1g" elasticsearch/swarm:5.0.0 -E cluster.name="ESCookBook" -E node.master=false -E node.data=true -E discovery.zen.ping.unicast.hosts=es_master

docker service create --network es_cluster --name es_ingest --constraint 'node.labels.type == es_ingest' --replicas=1 --env ES_JAVA_OPTS="-Xms1g -Xmx1g" elasticsearch/swarm:5.0.0 -E cluster.name="ESCookBook" -E node.master=false -E node.data=false -E node.ingest=true -E discovery.zen.ping.unicast.hosts=es_master

echo ""
echo "-------------------------------------------------------------------"
echo "Running Portainer to manage Swarm cluster at $SWARM_MANAGER node..."
echo "-------------------------------------------------------------------"
docker run -d --name portainer -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer -H unix:///var/run/docker.sock

docker service ls
echo ""
echo "--------------------------------"
echo "ES cluster up running        ..."
echo "--------------------------------"

