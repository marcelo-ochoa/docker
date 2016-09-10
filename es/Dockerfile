#name of container: elasticsearch/swarm
#versison of container: 5.0.0
FROM elasticsearch:5.0.0
MAINTAINER Marcelo Ochoa  "marcelo.ochoa@gmail.com"

COPY config/elasticsearch.yml /usr/share/elasticsearch/config

EXPOSE 9200 9300
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["elasticsearch"]
