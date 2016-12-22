Download latest Apex distribution for example Oracle Application Express 5.1 - English language (http://download.oracle.com/otn/java/appexpress/apex_5.1_en.zip)
 (http://www.oracle.com/technetwork/developer-tools/apex/downloads/index.html)  
Copy apex_5.1_en.zip into this folder.
Initial sys/system password are defined at the first Docker start.  
Build your Oracle Official 11gXE image first using this template (https://github.com/oracle/docker-images/tree/master/OracleDatabase)  
Check first if is available, for example:  
```bash
[mochoa@localhost xe-apex-latest]$ docker images|grep "oracle/database"
oracle/database                                        11.2.0.2-xe              ba74688a297e        22 hours ago        1.206 GB
oracle/database                                        12.1.0.2-ee              af209128066e        5 days ago          11.72 GB
```
Build oracle-apex Docker image using buildDockerImage.sh script.
Before run-apex.sh create a directory and change permissions to 1000 using:
```bash
  sudo mkdir -p /home/data/db/apex
  sudo chown -R 1000:1000 /home/data/db/apex
```
With empty directories first execution will create a default database with password random generated.  
Log into Apex using http://localhost:8080/apex/apex_admin using "admin" default user and the above password (sys/system).  
And happy coding with latest Apex.
