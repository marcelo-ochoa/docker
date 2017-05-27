#!/bin/bash
docker run -d --privileged=true --name test --hostname test --shm-size=1g \
-p 1521:1521 -p 5500:5500 -p 9099:9099 \
-e ORACLE_SID=TEST \
-e ORACLE_PDB=PDB1 \
-v /etc/timezone:/etc/timezone:ro -e TZ="America/Argentina/Buenos_Aires" \
-v /home/data/db/test:/opt/oracle/oradata \
ols-official:2.0.1
