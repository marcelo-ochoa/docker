docker run --privileged=true --volume=/home/data/db/ols:/u01/app/oracle/data --name ols --hostname ols --detach=true --publish=1521:1521 --publish=9099:9099 ols:2.0.1
