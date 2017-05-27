delete force noprompt obsolete;
run
{
configure controlfile autobackup on;
configure default device type to disk;
configure device type disk parallelism 1;
configure controlfile autobackup format for device type disk clear;
allocate channel c1 device type disk;
backup format '/opt/oracle/oradata/backup/prod/%d_%D_%M_%Y_%U' as compressed backupset database;
}
delete force noprompt obsolete;
