# External mount points
echo "mkdir -p /home/docker/host;mount -t vboxsf -o uid=1000,gid=50 hosthome /home/docker/host;ln -s /home/docker/host/data/node1 /home/docker/data" | docker-machine ssh manager1 sudo tee /var/lib/boot2docker/bootsync.sh > /dev/null
echo "mkdir -p /home/docker/host;mount -t vboxsf -o uid=1000,gid=50 hosthome /home/docker/host;ln -s /home/docker/host/data/node2 /home/docker/data" | docker-machine ssh manager2 sudo tee /var/lib/boot2docker/bootsync.sh > /dev/null
echo "mkdir -p /home/docker/host;mount -t vboxsf -o uid=1000,gid=50 hosthome /home/docker/host;ln -s /home/docker/host/data/node3 /home/docker/data" | docker-machine ssh worker1 sudo tee /var/lib/boot2docker/bootsync.sh > /dev/null
echo "mkdir -p /home/docker/host;mount -t vboxsf -o uid=1000,gid=50 hosthome /home/docker/host;ln -s /home/docker/host/data/node4 /home/docker/data" | docker-machine ssh worker2 sudo tee /var/lib/boot2docker/bootsync.sh > /dev/null
echo "mkdir -p /home/docker/host;mount -t vboxsf -o uid=1000,gid=50 hosthome /home/docker/host;ln -s /home/docker/host/data/node5 /home/docker/data" | docker-machine ssh worker3 sudo tee /var/lib/boot2docker/bootsync.sh > /dev/null
echo "mkdir -p /home/docker/host;mount -t vboxsf -o uid=1000,gid=50 hosthome /home/docker/host;ln -s /home/docker/host/data/node6 /home/docker/data" | docker-machine ssh worker4 sudo tee /var/lib/boot2docker/bootsync.sh > /dev/null


# Network to interconnect ES cluster
docker network create -d overlay es_cluster

# Node afinity
docker node update --label-add type=es_master manager1
docker node update --label-add type=es_master manager2
docker node update --label-add type=es_data   worker1
docker node update --label-add type=es_data   worker2
docker node update --label-add type=es_data   worker3
docker node update --label-add type=es_ingest worker4


# Provisioning image with a modified config/elasticsearch.yml
eval $(docker-machine env manager1)
docker build -t "elasticsearch/swarm:5.0.0" .

eval $(docker-machine env manager2)
docker build -t "elasticsearch/swarm:5.0.0" .

eval $(docker-machine env worker1)
docker build -t "elasticsearch/swarm:5.0.0" .

eval $(docker-machine env worker2)
docker build -t "elasticsearch/swarm:5.0.0" .

eval $(docker-machine env worker3)
docker build -t "elasticsearch/swarm:5.0.0" .

eval $(docker-machine env worker4)
docker build -t "elasticsearch/swarm:5.0.0" .

eval $(docker-machine env manager1)

docker service create --network es_cluster --name es_master --constraint 'node.labels.type == es_master' --replicas=1 -p 9200:9200 -p 9300:9300 --env ES_JAVA_OPTS="-Xms1g -Xmx1g"  elasticsearch/swarm:5.0.0 -E bootstrap.ignore_system_bootstrap_checks=true -E cluster.name="ESCookBook" -E node.master=true -E node.data=false -E discovery.zen.ping.unicast.hosts=es_master
# Wait for master node up and running
sleep 60
export MASTER_NODE_HOST=$(docker service ps es_master|grep es_master.1|grep Running|awk '{print $4}')
export MASTER_NODE_NAME=$(docker service ps es_master|grep es_master.1|grep Running|awk '{print $2"."$1}')
export ES_MASTER_IP=$(docker-machine ssh $MASTER_NODE_HOST docker inspect --format='{{.NetworkSettings.Networks.es_cluster.IPAddress}}' $MASTER_NODE_NAME)

docker service create --network es_cluster --name es_data --constraint 'node.labels.type == es_data' --replicas=2 --env ES_JAVA_OPTS="-Xms1g -Xmx1g" elasticsearch/swarm:5.0.0 -E bootstrap.ignore_system_bootstrap_checks=true -E cluster.name="ESCookBook" -E node.master=false -E node.data=true -E discovery.zen.ping.unicast.hosts=es_master

docker service create --network es_cluster --name es_ingest --constraint 'node.labels.type == es_ingest' --replicas=1 --env ES_JAVA_OPTS="-Xms1g -Xmx1g" elasticsearch/swarm:5.0.0 -E bootstrap.ignore_system_bootstrap_checks=true -E cluster.name="ESCookBook" -E node.master=false -E node.data=false -E node.ingest=true -E discovery.zen.ping.unicast.hosts=es_master

# Wait for cluster startup
sleep 120
curl http://192.168.99.100:9200/_nodes/process?pretty

