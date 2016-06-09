Download oracle-xe-11.2.0-1.0.x86_64.rpm.zip (http://download.oracle.com/otn/linux/oracle11g/xe/oracle-xe-11.2.0-1.0.x86_64.rpm.zip)
Unzip and copy Disk1/oracle-xe-11.2.0-1.0.x86_64.rpm into this folder, if you want to include .rpm file into this directory
is possible to modify Docker file command with ADD http://someserver/oracle-xe-11.2.0-1.0.x86_64.rpm /home/oracle
If you want to change memory_target parameter edit Dockerfile first.
To change default sys/system password edit xe.rsp file first.
Build oracle-xe Docker image using buildDockerImage.sh script.
Before run-persistent.sh create:
  sudo mkdir -p /home/data/db/xe/oradata
  sudo mkdir -p /home/data/db/xe/fast_recovery_area
and change permissions to 54321 using:
  sudo mkdir -p chown -R 54321:54321 /home/data/db/xe
With empty directories first execution will create a default database with password defined into xe.rsp file.
Next executions have RDBMS with the point in time information of ./stop.sh execution.
To stop and remove ephemeral data such as logs and .trc files use ./stop.sh script.
To logging in a running database VM use ./attch.sh script.
To see log information during boot use ./log.sh script.
