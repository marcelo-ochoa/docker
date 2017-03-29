#!/bin/bash
# Sample call  sh ./deploy-storage.sh $COMPUTE_COOKIE $API_URL
# API_URL is at: Oracle Cloud Services -> Service Details:Oracle Compute Cloud Service: REST Endpoint
# COMPUTE_COOKIE is retrieved with
# curl -i -X POST -H "Content-Type: application/oracle-compute-v3+json" -d '{"user":"Compute-tdlscotas/mochoa@scotas.com","password":"-------"}' "$API_URL"authenticate/

set -e
echo ""
echo "---------------------------"
echo "Creating Disks for nodes..."
echo "---------------------------"
COMPUTE_COOKIE=$1
API_URL=$2
for i in $(awk '{print $1}' cloud.hosts); do
  echo "creating boot disk for $i node...";
  echo "{
  \"size\": \"10G\",
  \"properties\": [\"/oracle/public/storage/default\"],
  \"bootable\": true,
  \"imagelist\": \"/Compute-tdlscotas/mochoa@scotas.com/Ubuntu.16.10.amd64.20170307\",
  \"name\": \"/Compute-tdlscotas/mochoa@scotas.com/boot_$i\"
}" > /tmp/data.json;
  curl -i -X POST \
     -H "Cookie: $COMPUTE_COOKIE" \
     -H "Content-Type: application/oracle-compute-v3+json" \
     -H "Accept: application/oracle-compute-v3+json" \
     -d "@/tmp/data.json" "$2"storage/volume/;
  echo "creating repo disk for $i node...";
  echo "{
  \"size\": \"45G\",
  \"properties\": [\"/oracle/public/storage/latency\"],
  \"bootable\": false,
  \"name\": \"/Compute-tdlscotas/mochoa@scotas.com/repo_$i\"
}" > /tmp/data.json;
  curl -i -X POST \
     -H "Cookie: $COMPUTE_COOKIE" \
     -H "Content-Type: application/oracle-compute-v3+json" \
     -H "Accept: application/oracle-compute-v3+json" \
     -d "@/tmp/data.json" "$2"storage/volume/;
done;

echo ""
echo "-------------------------------------"
echo "Wait until all storages are online..."
echo "-------------------------------------"

