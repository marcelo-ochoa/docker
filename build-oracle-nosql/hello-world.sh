#!/bin/bash
export KVHOME `docker inspect --format='{{index .Config.Env 3}}' oracle-nosql/net`
export KVROOT `docker inspect --format='{{index .Config.Env 7}}' oracle-nosql/net`
echo hello world cluster using $KVHOME and $KVROOT

docker exec -t master javac -cp examples:lib/kvclient.jar examples/hello/HelloBigDataWorld.java
docker exec -t master java -cp examples:lib/kvclient.jar hello.HelloBigDataWorld -store mystore -host master -port 5000
