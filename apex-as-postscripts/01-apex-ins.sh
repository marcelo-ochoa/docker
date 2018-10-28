#!/bin/bash
cd $ORACLE_BASE/scripts/setup/apex
su -p oracle -c "sqlplus / as sysdba <<EOF
ALTER SESSION SET CONTAINER = $ORACLE_PDB;
@apexins.sql SYSAUX SYSAUX TEMP /i/
EOF"
su -p oracle -c "sqlplus / as sysdba <<EOF
ALTER SESSION SET CONTAINER = $ORACLE_PDB;
@apex_epg_config.sql $ORACLE_BASE/scripts/setup
EOF"
su -p oracle -c "sqlplus / as sysdba <<EOF
ALTER USER ANONYMOUS ACCOUNT UNLOCK;
EOF"
