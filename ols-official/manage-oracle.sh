#!/bin/bash
# fix ORA-04035: unable to allocate 4096 bytes of shared memory in shared object cache "JOXSHM" of size "1073741824"
mount -o remount,exec /dev/shm
# fix ORA-27106: system pages not available to allocate memory
sysctl vm.hugetlb_shm_group=54321

su - oracle -c "$ORACLE_BASE/runOls.sh $ORACLE_SID $ORACLE_PDB $ORACLE_PWD $ORACLE_CHARACTERSET"
