#!/bin/bash

########### Move DB files ############
function moveFiles {
   if [ ! -d $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID ]; then
      mkdir -p $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID/
   fi;
   
   mv $ORACLE_HOME/dbs/spfile$ORACLE_SID.ora $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID/
   mv $ORACLE_HOME/dbs/orapw$ORACLE_SID $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID/
   mv $ORACLE_HOME/network/admin/tnsnames.ora $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID/
   
   symLinkFiles;
}

########### Symbolic link DB files ############
function symLinkFiles {

   if [ ! -L $ORACLE_HOME/dbs/spfile$ORACLE_SID.ora ]; then
      ln -s $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID/spfile$ORACLE_SID.ora $ORACLE_HOME/dbs/spfile$ORACLE_SID.ora
   fi;
   
   if [ ! -L $ORACLE_HOME/dbs/orapw$ORACLE_SID ]; then
      ln -s $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID/orapw$ORACLE_SID $ORACLE_HOME/dbs/orapw$ORACLE_SID
   fi;
   
   if [ ! -L $ORACLE_HOME/network/admin/tnsnames.ora ]; then
      ln -s $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID/tnsnames.ora $ORACLE_HOME/network/admin/tnsnames.ora
   fi;
}

########### SIGTERM handler ############
function _term() {
   echo "Stopping container."
   echo "SIGTERM received, shutting down database!"
   sqlplus / as sysdba <<EOF
   shutdown immediate;
EOF
   lsnrctl stop
}

########### SIGKILL handler ############
function _kill() {
   echo "SIGKILL received, shutting down database!"
   sqlplus / as sysdba <<EOF
   shutdown abort;
EOF
   lsnrctl stop
}

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
   # Default for ORACLE PWD
   if [ "$ORACLE_PWD" == "" ]; then
      export ORACLE_PWD=oracle
   fi;

   cd ols;ant -Ddba.usr=sys -Ddba.pwd=$ORACLE_PWD -Ddb.str=$ORACLE_PDB install-ols
   echo "OLS installed"
}


############# Create DB ################
function createDB {

   # Auto generate ORACLE PWD
   ORACLE_PWD=`openssl rand -base64 8`
   echo "ORACLE AUTO GENERATED PASSWORD FOR SYS, SYSTEM AND PDBAMIN: $ORACLE_PWD";

   cp $ORACLE_BASE/$CONFIG_RSP $ORACLE_BASE/dbca.rsp

   sed -i -e "s|###ORACLE_SID###|$ORACLE_SID|g" $ORACLE_BASE/dbca.rsp
   sed -i -e "s|###ORACLE_PDB###|$ORACLE_PDB|g" $ORACLE_BASE/dbca.rsp
   sed -i -e "s|###ORACLE_PWD###|$ORACLE_PWD|g" $ORACLE_BASE/dbca.rsp

   mkdir -p $ORACLE_HOME/network/admin
   echo "NAME.DIRECTORY_PATH= {TNSNAMES, EZCONNECT, HOSTNAME}" > $ORACLE_HOME/network/admin/sqlnet.ora

   # Listener.ora
   echo "LISTENER = 
  (DESCRIPTION_LIST = 
    (DESCRIPTION = 
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1)) 
      (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521)) 
    ) 
  ) 

" > $ORACLE_HOME/network/admin/listener.ora

# Start LISTENER and run DBCA
   lsnrctl start &&
   dbca -silent -responseFile $ORACLE_BASE/dbca.rsp ||
    cat /opt/oracle/cfgtoollogs/dbca/$ORACLE_SID/$ORACLE_SID.log

   echo "$ORACLE_SID=localhost:1521/$ORACLE_SID" >> $ORACLE_HOME/network/admin/tnsnames.ora
   echo "$ORACLE_PDB= 
  (DESCRIPTION = 
    (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = $ORACLE_PDB)
    )
  )" >> $ORACLE_HOME/network/admin/tnsnames.ora

   sqlplus / as sysdba << EOF
      ALTER SYSTEM SET control_files='$ORACLE_BASE/oradata/$ORACLE_SID/control01.ctl' scope=spfile;
      ALTER PLUGGABLE DATABASE $ORACLE_PDB SAVE STATE;
EOF

  rm $ORACLE_BASE/dbca.rsp
  
  # Move database operational files to oradata
  moveFiles;

}

############# Start DB ################
function startDB {
   # Make sure audit file destination exists
   if [ ! -d $ORACLE_BASE/admin/$ORACLE_SID/adump ]; then
      mkdir -p $ORACLE_BASE/admin/$ORACLE_SID/adump
   fi;
   
   lsnrctl start
   sqlplus / as sysdba << EOF
      STARTUP;
EOF

}

############# MAIN ################

# Set SIGTERM handler
trap _term SIGTERM

# Set SIGKILL handler
trap _kill SIGKILL

# Default for ORACLE SID
if [ "$ORACLE_SID" == "" ]; then
   export ORACLE_SID=ORCLCDB
fi;

# Default for ORACLE PDB
if [ "$ORACLE_PDB" == "" ]; then
   export ORACLE_PDB=ORCLPDB1
fi;

# Check whether database already exists
if [ -d $ORACLE_BASE/oradata/$ORACLE_SID ]; then
   symLinkFiles;
   startDB;
   if [ ! -f $ORACLE_BASE/oradata/$ORACLE_SID/OLS_IS_INSTALLED ]; then
      patchODCI;
      installOLS;
      touch $ORACLE_BASE/oradata/$ORACLE_SID/OLS_IS_INSTALLED
   fi
else
   # Remove database config files, if they exist
   rm -f $ORACLE_HOME/dbs/spfile$ORACLE_SID.ora
   rm -f $ORACLE_HOME/dbs/orapw$ORACLE_SID
   rm -f $ORACLE_HOME/network/admin/tnsnames.ora
   
   createDB;
   patchODCI;
   installOLS;
   touch $ORACLE_BASE/oradata/$ORACLE_SID/OLS_IS_INSTALLED
fi;

echo "#########################"
echo "DATABASE IS READY TO USE!"
echo "#########################"

tail -f $ORACLE_BASE/diag/rdbms/*/*/trace/alert*.log &
childPID=$!
wait $childPID
