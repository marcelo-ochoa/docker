#!/bin/bash
docker_pid=$(docker ps --filter label=com.docker.swarm.service.name=nosql_master-1 -q)

grep -v "^#" script-topo.txt | while read line ;do
  docker exec -t $docker_pid java -jar lib/kvstore.jar runadmin -host master-1 -port 5000 $line;
done
