#!/bin/bash
export KVHOME `docker inspect --format='{{index .Config.Env 3}}' oracle-nosql/net`
export KVROOT `docker inspect --format='{{index .Config.Env 7}}' oracle-nosql/net`
echo starting cluster using $KVHOME and $KVROOT

mkdir -p /var/lib/docker/dockerfiles/tmp/kvroot1
mkdir -p /var/lib/docker/dockerfiles/tmp/kvroot2
mkdir -p /var/lib/docker/dockerfiles/tmp/kvroot3
docker network create -d bridge mycorp.com
docker-compose up -d
