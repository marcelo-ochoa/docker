# Before building this image oracle/database:12.1.0.2-ee must be available at your local registry
# See https://github.com/oracle/docker-images/blob/master/OracleDatabase/README.md for more details
# Finally build a new image using ./buildDockerImage.sh script
# To run a container using patch installed image you should pass at least three parameters:
#    ORACLE_SID
#    ORACLE_PDB
# for example:
# docker run -d --privileged=true --name test --hostname test \
#   -p 1521:1521 -p 5500:5500 \
#   -e ORACLE_SID=TEST \
#   -e ORACLE_PDB=PDB1 \
#   -v /home/data/db/test:/opt/oracle/oradata \
#   oracle/database:12.2.0.1.170718-ee

FROM	oracle/database:12.2.0.1-ee
MAINTAINER mochoa@scotas.com

ENV	PATCH_FILE=p26123830_122010_Linux-x86-64.zip

USER	root
WORKDIR	/home/oracle
COPY	$START_FILE $PATCH_FILE $ORACLE_BASE/
ADD     https://mikedietrichde.com/wp-content/scripts/12c/check_patches.sql $ORACLE_BASE/
RUN	chown oracle:dba $ORACLE_BASE/$PATCH_FILE $ORACLE_BASE/check_patches.sql

USER	oracle
RUN	unzip $ORACLE_BASE/$PATCH_FILE -d $INSTALL_DIR && \
	mv $ORACLE_HOME/rdbms/admin/preupgrade.jar $ORACLE_HOME/rdbms/admin/preupgrade.jar.old  && \
	rm -f $ORACLE_BASE/$PATCH_FILE

WORKDIR $INSTALL_DIR/26123830
RUN	$ORACLE_HOME/OPatch/opatch prereq CheckConflictAgainstOHWithDetail -ph . && \
	$ORACLE_HOME/OPatch/opatch apply -silent

WORKDIR /home/oracle
RUN	rm -rf $INSTALL_DIR

VOLUME ["$ORACLE_BASE/oradata"]
EXPOSE	1521 5500

# Define default command to start Oracle Database. 
CMD exec $ORACLE_BASE/$RUN_FILE
