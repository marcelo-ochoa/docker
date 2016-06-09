#!/bin/bash
export KVHOME `docker inspect --format='{{index .Config.Env 3}}' oracle-nosql/net`
export KVROOT `docker inspect --format='{{index .Config.Env 7}}' oracle-nosql/net`
echo ping cluster using $KVHOME and $KVROOT

docker exec -t master java -jar $KVHOME/lib/kvstore.jar ping -host master -port 5000
