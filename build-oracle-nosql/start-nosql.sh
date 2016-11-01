#!/bin/bash
mkdir -p $KVROOT
mkdir -p $KVROOT/data1
mkdir -p $KVROOT/data2
mkdir -p $KVROOT/data3
if [ -t $MASTER_NODE ]; then
	MASTER_NODE=master
fi

icount=1

stop_database() {
        java -Xmx256m -Xms256m -jar $KVHOME/lib/kvstore.jar stop -root $KVROOT
	exit
}

start_database() {
	nohup java -Xmx256m -Xms256m -jar $KVHOME/lib/kvstore.jar start -root $KVROOT &
}

deploy_admin() {
	let "icount += $(java -Xmx256m -Xms256m -jar $KVHOME/lib/kvstore.jar runadmin -host $MASTER_NODE -port 5000 show topology | grep sn|wc -l)"
        echo Joining as sn$icount to $MASTER_NODE
	java -Xmx256m -Xms256m -jar $KVHOME/lib/kvstore.jar runadmin -host $MASTER_NODE -port 5000 <<EOF
configure -name mystore
plan deploy-zone -name "MyCity" -name MyZone -rf 3 -wait
plan deploy-sn -znname MyZone -host $1 -port 5000 -wait
plan deploy-admin -sn sn$icount -port 5001 -wait
pool create -name MyPool
pool join -name MyPool -sn sn$icount
EOF
}

deploy_node() {
	let "icount += $(java -Xmx256m -Xms256m -jar $KVHOME/lib/kvstore.jar runadmin -host $MASTER_NODE -port 5000 show topology | grep sn|wc -l)"
        echo Joining as sn$icount to $MASTER_NODE
	java -Xmx256m -Xms256m -jar $KVHOME/lib/kvstore.jar runadmin -host $MASTER_NODE -port 5000 <<EOF
plan deploy-sn -znname MyZone -host $1 -port 5000 -wait
pool join -name MyPool -sn sn$icount
EOF
}

create_bootconfig() {
        [[ -n $NODE_TYPE ]] && [[ $NODE_TYPE = "m" ]] && java -jar $KVHOME/lib/kvstore.jar makebootconfig -root $KVROOT -port 5000 -admin 5001 -host "$(hostname -s)" -hahost "$(hostname -s)" -harange 5010,5020 -store-security none -capacity 3 -num_cpus 0 -memory_mb 0 -storagedir $KVROOT/data1 -storagedir $KVROOT/data2 -storagedir $KVROOT/data3
        [[ -n $NODE_TYPE ]] && [[ $NODE_TYPE = "s" ]] && java -jar $KVHOME/lib/kvstore.jar makebootconfig -root $KVROOT -port 5000 -host "$(hostname -s)" -hahost "$(hostname -s)" -harange 5010,5020 -store-security none -capacity 3 -num_cpus 0 -memory_mb 0 -storagedir $KVROOT/data1 -storagedir $KVROOT/data2 -storagedir $KVROOT/data3
}

trap stop_database SIGTERM

if [ ! -f $KVROOT/config.xml ]; then
	create_bootconfig
        start_database
        [[ -n $NODE_TYPE ]] && [[ $NODE_TYPE = "m" ]] && deploy_admin "$(hostname -s)"
        [[ -n $NODE_TYPE ]] && [[ $NODE_TYPE = "s" ]] && deploy_node "$(hostname -s)"
else
	start_database
fi

touch $KVROOT/snaboot_0.log
tail -f $KVROOT/snaboot_0.log
