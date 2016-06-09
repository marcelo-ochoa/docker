#!/bin/bash

PERSISTENT_DATA=/u01/app/oracle/data
export ORACLE_HOME=/u01/app/oracle/product/12.1.0.2/dbhome_1
export ORACLE_SID=$(hostname)

stop_database() {
	su - oracle -c "$ORACLE_HOME/bin/sqlplus / as sysdba" << EOF
	shutdown abort
	exit
EOF
	exit
}
start_database() {
	su - oracle -c "$ORACLE_HOME/bin/sqlplus / as sysdba" << EOF
	startup
	exit
EOF
}
create_pfile() {
	su - oracle -c "$ORACLE_HOME/bin/sqlplus -S / as sysdba" << EOF
	set echo off pages 0 lines 200 feed off head off sqlblanklines off trimspool on trimout on
	spool $PERSISTENT_DATA/init_$(hostname).ora
	select 'spfile="'||value||'"' from v\$parameter where name = 'spfile';
	spool off
	exit
EOF
}

trap stop_database SIGTERM

printf "LISTENER=(DESCRIPTION_LIST=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$(hostname))(PORT=1521))(ADDRESS=(PROTOCOL=IPC)(KEY=EXTPROC1521))))\n" > $ORACLE_HOME/network/admin/listener.ora
printf "$(hostname) = (DESCRIPTION = (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))) (CONNECT_DATA = (SERVER = DEDICATED) (SERVICE_NAME = $(hostname))))\n" > $ORACLE_HOME/network/admin/tnsnames.ora
chown oracle:oinstall $ORACLE_HOME/network/admin/listener.ora
chown oracle:oinstall $ORACLE_HOME/network/admin/tnsnames.ora
printf "export ORACLE_HOME=/u01/app/oracle/product/12.1.0.2/dbhome_1\n"  >>/home/oracle/.bashrc
printf "export ORACLE_SID=$(hostname)\n"  >>/home/oracle/.bashrc
printf "export JAVA_HOME=\$ORACLE_HOME/jdk\n"  >>/home/oracle/.bashrc
printf "export PATH=\$ORACLE_HOME/bin:\$JAVA_HOME/bin:/u01/app/oracle/data/ant/bin:\$PATH\n"  >>/home/oracle/.bashrc
printf "export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:\$LD_LIBRARY_PATH\n"  >>/home/oracle/.bashrc
printf "export TERM=ansi\n"  >>/home/oracle/.bashrc

# fix ORA-04035: unable to allocate 4096 bytes of shared memory in shared object cache "JOXSHM" of size "1073741824"
mount -o remount,exec /dev/shm
# fix ORA-27106: system pages not available to allocate memory
echo "vm.hugetlb_shm_group=54322" >>/etc/sysctl.conf
sysctl -p

su - oracle -c "$ORACLE_HOME/bin/lsnrctl start"
su - oracle -c "$ORACLE_HOME/bin/orapwd FILE=/u01/app/oracle/product/12.1.0.2/dbhome_1/dbs/orapw$(hostname) password=oracle"

if [ ! -f ${PERSISTENT_DATA}/DATABASE_IS_SETUP ]; then
	sed -i "s/{{ db_create_file_dest }}/\/u01\/app\/oracle\/data\/$(hostname)/" $PERSISTENT_DATA/db_install.dbt
	sed -i "s/{{ oracle_base }}/\/u01\/app\/oracle/" $PERSISTENT_DATA/db_install.dbt
	sed -i "s/{{ database_name }}/$(hostname)/" $PERSISTENT_DATA/db_install.dbt
	su - oracle -c "$ORACLE_HOME/bin/dbca -silent -createdatabase -templatename $PERSISTENT_DATA/db_install.dbt -gdbname $(hostname) -sid $(hostname) -syspassword oracle -systempassword oracle -dbsnmppassword oracle"
	create_pfile
	if [ $? -eq 0 ]; then
		touch ${PERSISTENT_DATA}/DATABASE_IS_SETUP
	fi
else
	mkdir -p /u01/app/oracle/admin/$(hostname)/adump
        chown oracle:oinstall /u01/app/oracle/admin/$(hostname)/adump
	su - oracle -c "$ORACLE_HOME/bin/sqlplus / as sysdba" << EOF
	startup pfile=$PERSISTENT_DATA/init_$(hostname).ora
	exit
EOF
fi

tail -f /u01/app/oracle/diag/rdbms/$(hostname)/*/trace/alert_$(hostname).log &
wait
