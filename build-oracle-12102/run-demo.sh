docker run --privileged=true --volume=/var/lib/docker/db/demo:/u01/app/oracle/data --name demo --hostname demo --detach=true --publish=1521:1521 oracle-rdbms:12.1.0.2
