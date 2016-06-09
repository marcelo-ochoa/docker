FROM	oraclelinux:6
MAINTAINER marcelo.ochoa@gmail.com
RUN	groupadd -g 54321 oinstall
RUN	groupadd -g 54322 dba
RUN	useradd -m -g oinstall -G oinstall,dba -u 54321 oracle
RUN	yum -y install oracle-rdbms-server-12cR1-preinstall perl wget unzip ant ant-contrib ant-junit
RUN	mkdir /u01
RUN	chown oracle:oinstall /u01
USER	oracle
WORKDIR	/home/oracle
COPY	linuxamd64_12102_database_1of2.zip /home/oracle/
COPY	linuxamd64_12102_database_2of2.zip /home/oracle/
COPY	responsefile_oracle12102.rsp /home/oracle/
RUN	unzip linuxamd64_12102_database_1of2.zip
RUN	unzip linuxamd64_12102_database_2of2.zip
RUN	rm linuxamd64_12102_database_1of2.zip linuxamd64_12102_database_2of2.zip
RUN	/home/oracle/database/runInstaller -silent -force -waitforcompletion -responsefile /home/oracle/responsefile_oracle12102.rsp -ignoresysprereqs -ignoreprereq
USER	root
RUN	/u01/app/oraInventory/orainstRoot.sh
RUN	/u01/app/oracle/product/12.1.0.2/dbhome_1/root.sh -silent
RUN	rm -rf /home/oracle/responsefile_oracle12102.rsp /home/oracle/database
WORKDIR	/home/oracle
RUN	mkdir -p /u01/app/oracle/data
RUN	chown oracle:oinstall /u01/app/oracle/data
COPY	manage-oracle.sh /home/oracle/
EXPOSE	1521
VOLUME ["/u01/app/oracle/data"]
CMD	[ "sh" , "-c" ,  "/home/oracle/manage-oracle.sh" ]
