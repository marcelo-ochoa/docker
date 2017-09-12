#!/bin/bash
cd $ORACLE_BASE/scripts/setup/apex
su -p oracle -c "sqlplus / as sysdba <<EOF
@apexins.sql SYSAUX SYSAUX TEMP /i/
EOF"
su -p oracle -c "sqlplus / as sysdba <<EOF
@apex_epg_config.sql /install
EOF"
