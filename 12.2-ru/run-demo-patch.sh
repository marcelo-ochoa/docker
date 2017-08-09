#!/bin/bash
docker run -d --privileged=true --name demo --hostname demo --shm-size=1g \
-p 1521:1521 -p 5500:5500 \
-e ORACLE_SID=TEST \
-e ORACLE_PDB=PDB1 \
-v /home/data/db/demo:/opt/oracle/oradata \
oracle/database:12.2.0.1-ee-26123830
