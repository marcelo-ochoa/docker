#!/bin/bash

PERSISTENT_DATA=/u01/app/oracle/data
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
export ORACLE_SID=XE

stop_database() {
        cp -f /u01/app/oracle/product/11.2.0/xe/dbs/spfileXE.ora /u01/app/oracle/oradata/
        cp -f /u01/app/oracle/product/11.2.0/xe/dbs/orapwXE /u01/app/oracle/oradata/
        cp -f /u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora /u01/app/oracle/oradata/
        cp -f /u01/app/oracle/product/11.2.0/xe/network/admin/tnsnames.ora /u01/app/oracle/oradata/
        cp -f /etc/oratab /u01/app/oracle/oradata/
	/etc/init.d/oracle-xe stop
	exit
}
start_database() {
	/etc/init.d/oracle-xe start
}
create_db() {
	/etc/init.d/oracle-xe configure responseFile=/home/oracle/xe.rsp
        cp -f /u01/app/oracle/product/11.2.0/xe/dbs/spfileXE.ora /u01/app/oracle/oradata/
        cp -f /u01/app/oracle/product/11.2.0/xe/dbs/orapwXE /u01/app/oracle/oradata/
        cp -f /u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora /u01/app/oracle/oradata/
        cp -f /u01/app/oracle/product/11.2.0/xe/network/admin/tnsnames.ora /u01/app/oracle/oradata/
        cp -f /etc/oratab /u01/app/oracle/oradata/
}

trap stop_database SIGTERM

# fix ORA-04035: unable to allocate 4096 bytes of shared memory in shared object cache "JOXSHM" of size "1073741824"
mount -t tmpfs shmfs -o size=4g,remount /dev/shm
# fix ORA-27106: system pages not available to allocate memory
echo "vm.hugetlb_shm_group=54322" >>/etc/sysctl.conf
sysctl -p

if [ ! -f /u01/app/oracle/oradata/spfileXE.ora ]; then
	create_db
else
	export CONFIGURE_RUN=true
	cp -f /u01/app/oracle/oradata/spfileXE.ora /u01/app/oracle/product/11.2.0/xe/dbs/spfileXE.ora
	cp -f /u01/app/oracle/oradata/orapwXE /u01/app/oracle/product/11.2.0/xe/dbs/orapwXE
	cp -f /u01/app/oracle/oradata/listener.ora /u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora
	cp -f /u01/app/oracle/oradata/tnsnames.ora /u01/app/oracle/product/11.2.0/xe/network/admin/tnsnames.ora
	cp -f /u01/app/oracle/oradata/oratab /etc/oratab
	chown oracle:oinstall /u01/app/oracle/product/11.2.0/xe/dbs/spfileXE.ora
	chown oracle:oinstall /u01/app/oracle/product/11.2.0/xe/dbs/orapwXE
	chown oracle:dba /etc/oratab
	chmod 664 /etc/oratab
	start_database
fi

tail -f /u01/app/oracle/diag/rdbms/xe/XE/trace/alert_XE.log &
wait
