#!/bin/bash
# Sample call  sh ./deploy-storage.sh "$COMPUTE_COOKIE" "$API_URL" "apiscotas" "mochoa@scotas.com"
# API_URL is at: Oracle Cloud Services -> Service Details:Oracle Compute Cloud Service: REST Endpoint
# COMPUTE_COOKIE is retrieved with
# curl -i -X POST -H "Content-Type: application/oracle-compute-v3+json" -d '{"user":"Compute-$IDNTTY/$USR_LOGIN","password":"-------"}' "$API_URL"authenticate/

set -e
echo ""
echo "---------------------------"
echo "Creating Disks for nodes..."
echo "---------------------------"
COMPUTE_COOKIE=$1
API_URL=$2
IDNTTY=$3
USR_LOGIN=$4
for i in $(awk '{print $1}' cloud.hosts); do
  echo "";
  echo "creating boot disk for $i node...";
  echo "{
  \"size\": \"12G\",
  \"properties\": [\"/oracle/public/storage/default\"],
  \"bootable\": true,
  \"imagelist\": \"/oracle/public/OL_7.2_UEKR4_x86_64\",
  \"name\": \"/Compute-$IDNTTY/$USR_LOGIN/boot_$i\"
}" > /tmp/data.json;
  curl -X POST \
     -H "Cookie: $COMPUTE_COOKIE" \
     -H "Content-Type: application/oracle-compute-v3+json" \
     -H "Accept: application/oracle-compute-v3+json" \
     -d "@/tmp/data.json" "$API_URL"storage/volume/;
  echo "creating repo disk for $i node...";
  echo "{
  \"size\": \"45G\",
  \"properties\": [\"/oracle/public/storage/latency\"],
  \"bootable\": false,
  \"name\": \"/Compute-$IDNTTY/$USR_LOGIN/repo_$i\"
}" > /tmp/data.json;
  curl -X POST \
     -H "Cookie: $COMPUTE_COOKIE" \
     -H "Content-Type: application/oracle-compute-v3+json" \
     -H "Accept: application/oracle-compute-v3+json" \
     -d "@/tmp/data.json" "$API_URL"storage/volume/;
done;

echo ""
echo "-------------------------------------"
echo "Wait until all storages are online..."
echo "-------------------------------------"

