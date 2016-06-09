docker run --privileged=true --volume=/var/lib/docker/db/ols:/u01/app/oracle/data --name ols --hostname ols --detach=true --publish=1521:1521 --publish=9099:9099 oracle-rdbms:12.1.0.2
