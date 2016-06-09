#!/bin/bash
export KVHOME `docker inspect --format='{{index .Config.Env 3}}' oracle-nosql/net`
export KVROOT `docker inspect --format='{{index .Config.Env 7}}' oracle-nosql/net`
echo hello world cluster using $KVHOME and $KVROOT

docker exec -t master javac -cp examples:lib/kvclient.jar examples/externaltables/UserInfo.java
docker exec -t master javac -cp examples:lib/kvclient.jar examples/externaltables/MyFormatter.java
docker exec -t master javac -cp examples:lib/kvclient.jar examples/externaltables/LoadCookbookData.java
docker exec -t master java -cp examples:lib/kvclient.jar externaltables.LoadCookbookData -store mystore -host slave1 -port 5000 -delete
