#!/bin/bash
docker run --shm-size=1g --name apex --hostname apex \
-p 1521:1521 -p 8080:8080 \
-v /home/data/db/apex:/u01/app/oracle/oradata \
oracle/apex-5.0.4_en:11.2.0.2-xe
