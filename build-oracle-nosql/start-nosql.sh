#!/bin/bash
mkdir -p $KVROOT
mkdir -p $KVROOT/data1
mkdir -p $KVROOT/data2
stop_database() {
        java -Xmx256m -Xms256m -jar $KVHOME/lib/kvstore.jar stop -root $KVROOT
	exit
}
start_database() {
	nohup java -Xmx256m -Xms256m -jar $KVHOME/lib/kvstore.jar start -root $KVROOT &
}
create_bootconfig() {
        [[ -n $NODE_TYPE ]] && [[ $NODE_TYPE = "m" ]] && java -jar $KVHOME/lib/kvstore.jar makebootconfig -root $KVROOT -storagedir $KVROOT/data1 -storagedir $KVROOT/data2 -port 5000 -admin 5001 -host "$(hostname -f)" -harange 5010,5020 -store-security none -capacity 2 -num_cpus 0 -memory_mb 0
        [[ -n $NODE_TYPE ]] && [[ $NODE_TYPE = "s" ]] && java -jar $KVHOME/lib/kvstore.jar makebootconfig -root $KVROOT -storagedir $KVROOT/data1 -storagedir $KVROOT/data2 -port 5000 -host "$(hostname -f)" -harange 5010,5020 -store-security none -capacity 2 -num_cpus 0 -memory_mb 0
}

trap stop_database SIGTERM

if [ ! -f $KVROOT/config.xml ]; then
	create_bootconfig
fi

start_database

touch $KVROOT/snaboot_0.log
tail -f $KVROOT/snaboot_0.log
