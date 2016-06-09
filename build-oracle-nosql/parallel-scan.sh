#!/bin/bash
export KVHOME `docker inspect --format='{{index .Config.Env 3}}' oracle-nosql/net`
export KVROOT `docker inspect --format='{{index .Config.Env 7}}' oracle-nosql/net`
echo parallel scan cluster using $KVHOME and $KVROOT

docker exec -t master javac -cp examples:lib/kvclient.jar examples/parallelscan/ParallelScanExample.java
docker exec -t master java -cp examples:lib/kvclient.jar parallelscan.ParallelScanExample -store mystore -host master -port 5000 -load 50000
docker exec -t master java -cp examples:lib/kvclient.jar parallelscan.ParallelScanExample -store mystore -host slave2 -port 5000 -where 99
