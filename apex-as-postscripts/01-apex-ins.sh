#!/bin/bash
cd /tmp/apex
su -p oracle -c "sqlplus / as sysdba <<EOF
ALTER SESSION SET CONTAINER = ${ORACLE_PDB:-XEPDB1};
@apexins.sql SYSAUX SYSAUX TEMP /i/
EOF"
su -p oracle -c "sqlplus / as sysdba <<EOF
ALTER SESSION SET CONTAINER = ${ORACLE_PDB:-XEPDB1};
@apex_epg_config.sql /tmp
EXEC DBMS_XDB.SETHTTPPORT(8080);
EOF"
su -p oracle -c "sqlplus / as sysdba <<EOF
ALTER USER ANONYMOUS ACCOUNT UNLOCK;
EOF"
