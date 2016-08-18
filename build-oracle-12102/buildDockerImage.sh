#!/bin/bash
export LOCALREPO=$(docker inspect --format='{{ .NetworkSettings.IPAddress }}' localrepo)
docker build --build-arg REPO_IP=$LOCALREPO -t "oracle-rdbms:12.1.0.2" .
