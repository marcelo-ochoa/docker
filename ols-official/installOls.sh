#!/bin/bash
# Check whether ORACLE_SID is passed on
export ORACLE_SID=${1:-ORCLCDB}

# Check whether ORACLE_PDB is passed on
export ORACLE_PDB=${2:-ORCLPDB1}

# NO Auto generate ORACLE PWD if not passed on, hardcode oracle is used
export ORACLE_PWD=${3:-"oracle"}
echo "ORACLE PASSWORD FOR SYS, SYSTEM AND PDBADMIN: $ORACLE_PWD";

########### Patch ODCI ############
function patchODCI() {
   echo "Patching ODCI library..."
   mv $ORACLE_HOME/rdbms/jlib/ODCI.jar $ORACLE_HOME/rdbms/jlib/ODCI.jar.orig
   cp /home/oracle/ODCI.jar $ORACLE_HOME/rdbms/jlib/ODCI.jar
   $ORACLE_HOME/perl/bin/perl $ORACLE_HOME/rdbms/admin/catcon.pl -d $ORACLE_HOME/rdbms/admin -b initsoxx_output initsoxx.sql
   echo "ODCI patched"
}

########### Install OLS ############
function installOLS() {
   echo "Installing OLS..."
   cd ols;ant -Ddba.usr=sys -Ddba.pwd=$ORACLE_PWD -Ddb.str=$ORACLE_PDB install-ols >/home/oracle/install-OLS.log 2>/home/oracle/install-OLS.err
   echo "OLS installed see /home/oracle/install-OLS.log and /home/oracle/install-OLS.err files for details"
}


# Sanity checks Check whether database already exists
if [ ! -f $ORACLE_BASE/oradata/$ORACLE_SID/OLS_IS_INSTALLED ]; then
      patchODCI;
      installOLS;
      touch $ORACLE_BASE/oradata/$ORACLE_SID/OLS_IS_INSTALLED
      echo "OLS Installed OK...."
fi;
