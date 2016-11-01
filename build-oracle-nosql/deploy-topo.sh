#!/bin/bash
export KVHOME `docker inspect --format='{{index .Config.Env 3}}' oracle-nosql/net`
export KVROOT `docker inspect --format='{{index .Config.Env 7}}' oracle-nosql/net`
echo deploying cluster using $KVHOME and $KVROOT

grep -v "^#" script-topo.txt | while read line ;do
  docker exec -t master java -jar $KVHOME/lib/kvstore.jar runadmin -host master -port 5000 $line;
done
