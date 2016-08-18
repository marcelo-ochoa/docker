#!/bin/bash
export LOCALREPO=$(docker inspect --format='{{ .NetworkSettings.IPAddress }}' localrepo)
docker build --build-arg REPO_IP=$LOCALREPO -t "oracle-xe:11.2.0-1.0" .
