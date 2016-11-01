#!/bin/bash
# fix ORA-04035: unable to allocate 4096 bytes of shared memory in shared object cache "JOXSHM" of size "1073741824"
mount -o remount,exec /dev/shm
# fix ORA-27106: system pages not available to allocate memory
echo "vm.hugetlb_shm_group=54322" >>/etc/sysctl.conf
sysctl -p

echo "export ORACLE_SID=$ORACLE_SID" >>/home/oracle/.bashrc
echo "export ORACLE_PDB=$ORACLE_PDB" >>/home/oracle/.bashrc

su - oracle -c "$ORACLE_BASE/runOls.sh"
