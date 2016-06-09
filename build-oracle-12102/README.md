Download linuxamd64_12102_database_1of2.zip and linuxamd64_12102_database_2of2.zip at
 (http://www.oracle.com/technetwork/database/enterprise-edition/downloads/index.html)  
Copy both files into this folder.
Initial sys/system password are defined into manage-oracle.sh file.  
All oracle related parameters are defined into db_install.dbt file.  
Build oracle-rdbms Docker image using buildDockerImage.sh script.
Before run.sh create and change permissions to 54321 using:
```bash
  sudo mkdir -p /home/data/db/ols
  sudo cp db_install.dbt /home/data/db/ols
  sudo mkdir -p chown -R 54321:54321 /home/data/db/ols
```
With empty directories first execution will create a default database with password defined into manage-oracle.sh file.  
Next executions have RDBMS with the point in time information of ./stop.sh execution.  
To stop and remove ephemeral data such as logs and .trc files use ./stop.sh script.  
To logging in a running database VM use ./attch.sh script.  
To see log information during boot use ./log.sh script.  
