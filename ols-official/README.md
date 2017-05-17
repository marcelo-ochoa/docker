Scotas OLS official on Docker
===============
Sample Docker build files to facilitate installation, configuration, and environment setup for DevOps users. For more information about Scotas OLS please see the 
[Scotas OLS | Oracle + Solr Lucene](http://www.scotas.com/products).

## How to build and run
This project offers sample Dockerfiles for:
 * Scotas OLS on top of Oracle Database 12c Release 1 (12.1.0.2) Enterprise Edition

To assist in building the images, you can use the [buildDockerImage.sh](buildDockerImage.sh) script. See below for instructions and usage.

The `buildDockerImage.sh` script is just a utility shell script that performs an easy way for beginners to get started. Expert users are welcome to
directly call `docker build` with their prefered set of parameters.

### Building Scotas OLS Docker Install Images
**IMPORTANT:** You will have to provide the Oracle Database base image at your local repository.
See this [README.md](https://github.com/oracle/docker-images/blob/master/OracleDatabase/README.md) file for more instructions.

Before you build the image make sure that you have a oracle/database:12.1.0.2-ee ready for example:


     [mochoa@localhost ols-official]$ docker image ls|grep oracle
     ....
     oracle/database                                       12.1.0.2-ee              342cc4c79645        22 hours ago        11.2 GB
     ....

**IMPORTANT:** The resulting images will be an image with the Scotas OLS binaries installed. On first startup of the container a new database will be created,
the following lines highlight when the database is ready to be used:

     ODCI patched
     Installing OLS...
     OLS installed see /home/oracle/install-OLS.log and /home/oracle/install-OLS.err files for details
     OLS Installed OK....
     #########################
     DATABASE IS READY TO USE!
     #########################

### Running Scotas OLS in a Docker container

#### Running Scotas OLS on top of Oracle Enterprise Edition in a Docker container
To run your Scotas OLS Docker image use the **docker run** command as follows:

	docker run --name <container name> \
	-p <host port>:1521 -p <host port>:5500 \
	-e ORACLE_SID=<your SID> \
	-e ORACLE_PDB=<your PDB name> \
	-e ORACLE_PWD=<your database passwords> \
	-e ORACLE_CHARACTERSET=<your character set> \
	-v [<host mount point>:]/opt/oracle/oradata \
	ols-official:2.0.1
	
	Parameters:
	   --name:        The name of the container (default: auto generated)
	   -p:            The port mapping of the host port to the container port. 
	                  Two ports are exposed: 1521 (Oracle Listener), 5500 (OEM Express)
                          Optional 9099 if you want to control Solr logging level
	   -e ORACLE_SID: The Oracle Database SID that should be used, required parameter
	   -e ORACLE_PDB: The Oracle Database PDB name that should be used, required parameter
	   -e ORACLE_PWD: The Oracle Database SYS, SYSTEM and PDB_ADMIN password, required parameter
	   -e ORACLE_CHARACTERSET:
	                  The character set to use when creating the database (default: AL32UTF8)
	   -v             The data volume to use for the database.
	                  Has to be owned by the Unix user "oracle" (chown 54321:54321 <host mount point>) or set appropriately.
	                  If omitted the database will not be persisted over container recreation.

There are two ports that are exposed in this image:
* 1521 which is the port to connect to the Oracle Database.
* 5500 which is the port of OEM Express.

The password for SYS/SYSTEM and PDB_ADMIN accounts can be changed via the **docker exec** command. **Note**, the container has to be running:

	docker exec test su - oracle -c "/opt/oracle/setPassword.sh <your password>"

Once the container has been started you can connect to it just like to any other database:

	sqlplus sys/<your password>@//localhost:1521/TEST as sysdba
	sqlplus system/<your password>@//localhost:1521/TEST

### Running SQL*Plus in a Docker container
You may use the same Oracle Docker image which was used as base image for ols-official:2.0.1, to run `sqlplus` to connect to it, for example:

	docker run --rm -ti oracle/database:12.1.0.2-ee sqlplus pdbadmin/<yourpassword>@//<db-container-ip>:1521/ORCLPDB1

Another option is to use `docker exec` and run `sqlplus` from within the same container already running the database:

	docker exec -ti <container name> /bin/bash
        bash-4.2# su -l oracle
        Last login: Wed May 17 11:38:57 UTC 2017
        [oracle@test ~]$ sqlplus pdbadmin@PDB1

## Known issues
* The [`overlay` storage driver](https://docs.docker.com/engine/userguide/storagedriver/selectadriver/) on CentOS has proven to run into Docker bug #25409. We recommend 
using `btrfs` or `overlay2` instead. For more details see issue [#317](https://github.com/oracle/docker-images/issues/317).
* Unlike Oracle Docker images Scotas OLS installer do not work with random generated password, ORACLE_PWD must be passed in first run of the container
when the Database is created and OLS is installed
* Unlike Oracle Docker images this container run as root at the entry point for starting the Database, this fixs:
  - ORA-04035: unable to allocate 4096 bytes of shared memory in shared object cache "JOXSHM" of size "1073741824"
  - ORA-27106: system pages not available to allocate memory

## Support
Contact Scotas OLS support at [info@scotas.com](mailto:info@scotas.com)

