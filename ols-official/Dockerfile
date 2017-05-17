# Before building this image oracle/database:12.1.0.2-ee must be available at your private registry
# See https://github.com/oracle/docker-images/blob/master/OracleDatabase/README.md for more details
# Finally build using ./buildDockerImage.sh script
# To run a container using OLS image you should pass at least three parameters:
#    ORACLE_SID
#    ORACLE_PDB
#    ORACLE_PWD
# for example:
# docker run -d --privileged=true --name test --hostname test \
#   -p 1521:1521 -p 5500:5500 \
#   -e ORACLE_SID=TEST \
#   -e ORACLE_PDB=PDB1 \
#   -e ORACLE_PWD="Oracle2017!" \
#   -v /home/data/db/test:/opt/oracle/oradata \
#   ols-official:2.0.1

FROM	oracle/database:12.1.0.2-ee
MAINTAINER mochoa@scotas.com

USER	root
RUN	yum -y install ant ant-contrib ant-junit  && \
	yum clean all

WORKDIR	/home/oracle
ADD	http://www.scotas.com/download/ols/lucene-ols-bin-2.0.1.zip /home/oracle/
ADD	http://www.scotas.com/download/ols/valid.ols /home/oracle/
ADD	http://www.scotas.com/download/ols/ODCI.jar /home/oracle/
COPY 	runOls.sh installOls.sh $ORACLE_BASE/
RUN	chown -R oracle:oinstall /home/oracle/lucene-ols-bin-2.0.1.zip && \
	chown -R oracle:oinstall /home/oracle/valid.ols && \
	chown -R oracle:oinstall /home/oracle/ODCI.jar && \
        chown -R oracle:oinstall $ORACLE_BASE/installOls.sh && \
	chown -R oracle:oinstall $ORACLE_BASE/runOls.sh
RUN	unzip /home/oracle/lucene-ols-bin-2.0.1.zip -d /home/oracle/ && \
	chown -R oracle:oinstall /home/oracle/ols && \
	cp /home/oracle/valid.ols /home/oracle/ols/bin/com/scotas/license && \
	rm -f /home/oracle/lucene-ols-bin-2.0.1.zip
RUN	echo "export ORACLE_BASE=$ORACLE_BASE" >>/home/oracle/.bashrc && \
	echo "export ORACLE_HOME=$ORACLE_HOME" >>/home/oracle/.bashrc && \
	echo "export INSTALL_FILE_1=$INSTALL_FILE_1" >>/home/oracle/.bashrc && \
	echo "export INSTALL_FILE_2=$INSTALL_FILE_2" >>/home/oracle/.bashrc && \
	echo "export INSTALL_RSP=$INSTALL_RSP" >>/home/oracle/.bashrc && \
	echo "export CONFIG_RSP=$CONFIG_RSP" >>/home/oracle/.bashrc && \
	echo "export PWD_FILE=$PWD_FILE" >>/home/oracle/.bashrc  && \
	echo "export PERL_INSTALL_FILE=$PERL_INSTALL_FILE" >>/home/oracle/.bashrc && \
	echo "export RUN_FILE=$RUN_FILE" >>/home/oracle/.bashrc && \
	echo "export START_FILE=$START_FILE" >>/home/oracle/.bashrc && \
	echo "export CREATE_DB_FILE=$CREATE_DB_FILE" >>/home/oracle/.bashrc && \
	echo "export SETUP_LINUX_FILE=$SETUP_LINUX_FILE" >>/home/oracle/.bashrc && \
	echo "export CHECK_SPACE_FILE=$CHECK_SPACE_FILE" >>/home/oracle/.bashrc && \
	echo "export CHECK_DB_FILE=$CHECK_DB_FILE" >>/home/oracle/.bashrc && \
        echo "export INSTALL_DB_BINARIES_FILE=$INSTALL_DB_BINARIES_FILE" >>/home/oracle/.bashrc && \
	echo "export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch/:/usr/sbin:$PATH" >>/home/oracle/.bashrc && \
	echo "export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/usr/lib"  >>/home/oracle/.bashrc && \
	echo "export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib" >>/home/oracle/.bashrc


COPY	manage-oracle.sh /home/oracle/

VOLUME ["$ORACLE_BASE/oradata"]
EXPOSE	1521 5500 9099 9999

# Define default command to start Oracle Database. 
CMD	exec /home/oracle/manage-oracle.sh
