#!/bin/bash
export KVHOME `docker inspect --format='{{index .Config.Env 3}}' oracle-nosql/net`
export KVROOT `docker inspect --format='{{index .Config.Env 7}}' oracle-nosql/net`
echo starting cluster using $KVHOME and $KVROOT

mkdir -p /var/lib/docker/dockerfiles/tmp/kvroot1
mkdir -p /var/lib/docker/dockerfiles/tmp/kvroot2
mkdir -p /var/lib/docker/dockerfiles/tmp/kvroot3
docker network create -d bridge mycorp.com
docker run -d -t --volume=/var/lib/docker/dockerfiles/tmp/kvroot1:$KVROOT --net=mycorp.com --publish=5000:5000 --publish=5001:5001 -e NODE_TYPE=m -P \
  --name master -h master.mycorp.com oracle-nosql/net
docker run -d -t --volume=/var/lib/docker/dockerfiles/tmp/kvroot2:$KVROOT --net=mycorp.com -e NODE_TYPE=s -P --name slave1 -h slave1.mycorp.com oracle-nosql/net
docker run -d -t --volume=/var/lib/docker/dockerfiles/tmp/kvroot3:$KVROOT --net=mycorp.com -e NODE_TYPE=s -P --name slave2 -h slave2.mycorp.com oracle-nosql/net
