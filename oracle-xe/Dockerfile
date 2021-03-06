FROM	oraclelinux:latest
MAINTAINER marcelo.ochoa@gmail.com
# Local repository IP address to find Oracle installable .zip file
ARG REPO_IP

RUN	groupadd -g 54321 oinstall
RUN	groupadd -g 54322 dba
RUN	useradd -m -g oinstall -G oinstall,dba -u 54321 oracle
RUN	yum -y install unzip libaio bc initscripts net-tools && \
	yum clean all
RUN	chown -R oracle:oinstall /home/oracle
RUN	chmod g+rx /home/oracle
RUN	chmod o+rx /home/oracle
ADD	xe.rsp /home/oracle/
RUN	curl -sSL http://$REPO_IP/oracle-xe-11.2.0-1.0.x86_64.rpm.zip -o /home/oracle/oracle-xe-11.2.0-1.0.x86_64.rpm.zip && \
	unzip /home/oracle/oracle-xe-11.2.0-1.0.x86_64.rpm.zip -d /home/oracle && \
	rpm2cpio /home/oracle/Disk1/oracle-xe-11.2.0-1.0.x86_64.rpm | cpio -idmv && \
	rm -rf /home/oracle/Disk1
RUN	mkdir /u01/app/oracle/oradata
RUN	mkdir /u01/app/oracle/product/11.2.0/xe/config/log
RUN	mkdir -p /u01/app/oracle/diag/rdbms/xe/XE/trace/
RUN	umask 0027
RUN	mkdir -p /u01/app/oracle/admin/XE/adump
RUN	mkdir -p /u01/app/oracle/admin/XE/dpdump
RUN	mkdir -p /u01/app/oracle/admin/XE/pfile
RUN	mkdir -p /u01/app/oracle/admin/cfgtoollogs/dbca/XE
RUN	mkdir -p /u01/app/oracle/admin/XE/dbs
RUN	mkdir -p /u01/app/oracle/fast_recovery_area
RUN	umask 0022
RUN	touch /u01/app/oracle/diag/rdbms/xe/XE/trace/alert_XE.log
RUN	chown -R oracle:oinstall /u01/app/oracle
RUN	chmod u+x /etc/init.d/oracle-xe
RUN	sed -i -e 's/%memory_target%/1G/g' /u01/app/oracle/product/11.2.0/xe/config/scripts/init.ora
RUN	sed -i -e 's/%memory_target%/1G/g' /u01/app/oracle/product/11.2.0/xe/config/scripts/initXETemp.ora
RUN	find /u01/app/oracle/product/11.2.0/xe -name "*.sh" -exec chmod u+x {} \;
RUN	echo ". /u01/app/oracle/product/11.2.0/xe/bin/oracle_env.sh" >>/home/oracle/.bashrc
COPY	manage-oracle.sh /home/oracle/
EXPOSE	1521 8080
VOLUME ["/u01/app/oracle/oradata","/u01/app/oracle/fast_recovery_area"]
CMD	[ "sh" , "-c" ,  "/home/oracle/manage-oracle.sh" ]
