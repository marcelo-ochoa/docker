FROM	oracle/database:12.1.0.2-ee
MAINTAINER mochoa@scotas.com


ARG ORACLE_SID
ARG ORACLE_PDB

USER	root
RUN	yum -y install ant ant-contrib ant-junit  && \
	yum clean all

WORKDIR	/home/oracle
ADD	http://www.scotas.com/download/ols/lucene-ols-bin-2.0.1.zip /home/oracle/
ADD	http://www.scotas.com/download/ols/valid.ols /home/oracle/
ADD	http://www.scotas.com/download/ols/ODCI.jar /home/oracle/
COPY 	runOls.sh $ORACLE_BASE/
RUN	chown -R oracle:oinstall /home/oracle/lucene-ols-bin-2.0.1.zip && \
	chown -R oracle:oinstall /home/oracle/valid.ols && \
	chown -R oracle:oinstall /home/oracle/ODCI.jar && \
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
        echo "export INSTALL_DIR=$ORACLE_BASE/install" >>/home/oracle/.bashrc && \
	echo "export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch/:/usr/sbin:$PATH" >>/home/oracle/.bashrc && \
	echo "export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/usr/lib"  >>/home/oracle/.bashrc && \
	echo "export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib" >>/home/oracle/.bashrc


COPY	manage-oracle.sh /home/oracle/

VOLUME ["/opt/oracle/oradata"]
EXPOSE	1521 5500 9099 9999

# Define default command to start Oracle Database. 
CMD	[ "sh" , "-c" ,  "/home/oracle/manage-oracle.sh" ]
