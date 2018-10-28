# Post-install script of Docker Oracle 18c XE images to upgrade to Apex 18.2

You can use Oracle  18c XE(https://github.com/marcelo-ochoa/docker-images/tree/master/OracleDatabase/SingleInstance/dockerfiles/18.4.0) image on Docker with latest Apex available for downloading at Oracle OTN Web Site, now 18.2 release (http://www.oracle.com/technetwork/developer-tools/apex/downloads/index.html), by simple adding three shell scripts.

First you have to build your Oracle 18c base image by running the script downloaded from GitHub and providing the rpm binary installation at docker-images/OracleDatabase/SingleInstance/dockerfiles/18.4.0/ directory, here a sample directory content structure:

    [oracle@localhost 18.4.0]$ tree
    .
    ├── checkDBStatus.sh
    ├── Checksum.xe
    ├── Dockerfile.xe
    ├── oracle-database-xe-18c-1.0-1.x86_64.rpm
    ├── oracle-xe-18c.conf
    ├── runOracle.sh
    └── setPassword.sh
    0 directories, 7 files

next at the parent directory run this command:

    [oracle@localhost dockerfiles]$ ./buildDockerImage.sh -v 18.4.0 -x

as a result of the docker build command you will get a fresh local image of 18c XE ready to use:

    [oracle@localhost dockerfiles]$ docker image ls|grep oracle
    oracle/database                                       18.4.0-xe                4a22e4af8263        4 days ago          8.57GB

latest Oracle scripts include a hook to provide extra functionality as post installation task, here an example of custom scripts(https://github.com/oracle/docker-images/tree/master/OracleDatabase/SingleInstance/samples/customscripts), so if we start a container as:

    docker run --name xe-18c --hostname xe-18c --shm-size=1g \
    -p 1521:1521 -p 5500:5500 -p 8080:8080 \
    -e ORACLE_PWD=<your database passwords> \
    -v [<host mount point>:]/opt/oracle/oradata \
    -v $PWD/apex-as-postscripts:/opt/oracle/scripts/setup \
    oracle/database:18.4.0-xe

The content of directory apex-as-postscripts is:

    [oracle@localhost apex-as-postscripts]$ tree
    .
    ├── 00-unzip-apex.sh
    ├── 01-apex-ins.sh
    ├── 02-clean-up-files.sh
    ├── apex_18.2_en.zip
    └── README.md
    0 directories, 5 files

You can download these scripts at my GitHub (https://github.com/marcelo-ochoa/docker/tree/master/apex-as-postscripts), but before starting your docker container put inside the directory the Apex distribution file apex_18.2_en.zip. For newer releases simple put a new zip and edit 00-unzip-apex.sh script with a proper file name.

**IMPORTANT:** The resulting images will be an image with the Oracle binaries installed. On first startup of the container a new database will be created, the following lines highlight when the database is ready to be used:

    #########################
    DATABASE IS READY TO USE!
    #########################
