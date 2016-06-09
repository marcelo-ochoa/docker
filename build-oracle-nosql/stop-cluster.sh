#!/bin/bash
export KVHOME `docker inspect --format='{{index .Config.Env 3}}' oracle-nosql/net`
export KVROOT `docker inspect --format='{{index .Config.Env 7}}' oracle-nosql/net`
echo stoping cluster using $KVHOME and $KVROOT

docker stop master
docker stop slave1
docker stop slave2
docker rm master
docker rm slave1
docker rm slave2
docker network rm mycorp.com
