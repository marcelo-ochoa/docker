#!/bin/bash

# docker-compose.yml envs and defaults
MASTER_NODE=${MASTER_NODE:-master-1}
if [ -t $KVROOT ]; then
	KVROOT="/kvroot"
fi

icount=1

stop_database() {
	echo "trap received, shutdown..."
    java -Xmx256m -Xms256m -jar $KVHOME/lib/kvstore.jar stop -root $KVROOT
	exit
}

start_database() {
	nohup java -Xmx256m -Xms256m -jar $KVHOME/lib/kvstore.jar start -root $KVROOT &
}

deploy_admin() {
	sleep 10
	let "icount += $(java -Xmx256m -Xms256m -jar $KVHOME/lib/kvstore.jar runadmin -host $MASTER_NODE -port 5000 show topology | grep sn|wc -l)"
    echo Joining as sn$icount to $MASTER_NODE using hostname:$1
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
	sleep "$(( ( RANDOM % 5 ) * 10  + 20 ))"
	let "icount += $(java -Xmx256m -Xms256m -jar $KVHOME/lib/kvstore.jar runadmin -host $MASTER_NODE -port 5000 show topology | grep sn|wc -l)"
    echo Joining as sn$icount to $MASTER_NODE using hostname:$1
	java -Xmx256m -Xms256m -jar $KVHOME/lib/kvstore.jar runadmin -host $MASTER_NODE -port 5000 <<EOF
plan deploy-sn -znname MyZone -host $1 -port 5000 -wait
pool join -name MyPool -sn sn$icount
EOF
}

create_bootconfig() {
	mkdir -p /data/1 /data/2 /data/3
    [[ -n $NODE_TYPE ]] && [[ $NODE_TYPE = "m" ]] && java -jar $KVHOME/lib/kvstore.jar makebootconfig -root $KVROOT -port 5000 -admin 5001 -host "$HOSTNAME" -hahost "$HOSTNAME" -harange 5010,5020 -store-security none -capacity 3 -num_cpus 1 -memory_mb 1024 -storagedir /data/1 -storagedirsize 1_gb -storagedir /data/2 -storagedirsize 1_gb -storagedir /data/3 -storagedirsize 1_gb
    [[ -n $NODE_TYPE ]] && [[ $NODE_TYPE = "s" ]] && java -jar $KVHOME/lib/kvstore.jar makebootconfig -root $KVROOT -port 5000 -host "$HOSTNAME" -hahost "$HOSTNAME" -harange 5010,5020 -store-security none -capacity 3 -num_cpus 1 -memory_mb 1024 -storagedir /data/1 -storagedirsize 1_gb -storagedir /data/2 -storagedirsize 1_gb -storagedir /data/3 -storagedirsize 1_gb
}

# Set SIGINT handler
trap stop_database SIGINT

# Set SIGTERM handler
trap stop_database SIGTERM

# Set SIGKILL handler
trap stop_database SIGKILL

if [ ! -f $KVROOT/config.xml ]; then
	create_bootconfig
    start_database
    [[ -n $NODE_TYPE ]] && [[ $NODE_TYPE = "m" ]] && deploy_admin "$MASTER_NODE"
    [[ -n $NODE_TYPE ]] && [[ $NODE_TYPE = "s" ]] && deploy_node "$HOSTNAME"
else
	start_database
fi

touch $KVROOT/snaboot_0.log
tail -f $KVROOT/snaboot_0.log &
childPID=$!
wait $childPID
