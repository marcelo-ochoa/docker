#!/bin/bash
exec -ti test su - oracle -c "/opt/oracle/product/12.1.0.2/dbhome_1/bin/rman target=/ cmdfile='/opt/oracle/oradata/backup_full_compressed.sh' log='/opt/oracle/oradata/backup_archive.log'"
