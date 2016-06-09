docker run --privileged=true --volume=/home/data/db/ols:/u01/app/oracle/data --name ols --hostname ols --detach=true --publish=1521:1521 oracle-rdbms:12.1.0.2
