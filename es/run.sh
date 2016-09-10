#!/usr/bin/env bash
docker run -it -e ES_JAVA_OPTS="-Xms1g -Xmx1g" -v "$PWD/config":/usr/share/elasticsearch/config -v "$PWD/esdata":/usr/share/elasticsearch/data --publish 9200:9200 --publish 9300:9300 elasticsearch:5.0.0 -E bootstrap.ignore_system_bootstrap_checks=true -E cluster.name=ESCookBook -E node.name="NodeName"
