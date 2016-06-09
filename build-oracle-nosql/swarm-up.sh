#!/bin/bash
set -e
docker-machine start proxy

export CONSUL_IP=$(docker-machine ip proxy)
export PROXY_IP=$(docker-machine ip proxy)
eval $(docker-machine env proxy)
export DOCKER_IP=$(docker-machine ip proxy)

docker-compose -f docker-compose-registrator.yml up -d consul proxy
docker-machine start swarm-master
docker-machine start swarm-node-1
docker-machine start swarm-node-2
eval $(docker-machine env swarm-master)

export DOCKER_IP=$(docker-machine ip swarm-master)

docker-compose -f docker-compose-registrator.yml up -d registrator

eval $(docker-machine env swarm-node-1)

export DOCKER_IP=$(docker-machine ip swarm-node-1)

docker-compose -f docker-compose-registrator.yml up -d registrator

eval $(docker-machine env swarm-node-2)

export DOCKER_IP=$(docker-machine ip swarm-node-2)

docker-compose -f docker-compose-registrator.yml up -d registrator

export DOCKER_IP=$(docker-machine ip swarm-master)
eval $(docker-machine env --swarm swarm-master)

docker-compose -p nosql -f docker-compose.yml up -d
