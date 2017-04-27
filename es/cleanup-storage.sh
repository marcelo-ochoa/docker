#!/bin/bash
# Sample call  sh ./cleanup-storage.sh "$COMPUTE_COOKIE" "$API_URL" "apiscotas" "mochoa@scotas.com"
# API_URL is at: Oracle Cloud Services -> Service Details:Oracle Compute Cloud Service: REST Endpoint
# COMPUTE_COOKIE is retrieved with
# curl -i -X POST -H "Content-Type: application/oracle-compute-v3+json" -d '{"user":"Compute-apiscotas/mochoa@scotas.com","password":"-------"}' "$API_URL"authenticate/

set -e
echo ""
echo "---------------------------"
echo "Dropping Disks for nodes..."
echo "---------------------------"
COMPUTE_COOKIE=$1
API_URL=$2
IDNTTY=$3
USR_LOGIN=$4
for i in $(awk '{print $1}' cloud.hosts); do
  echo "deleting boot disk for $i node...";
  curl -X DELETE \
     -H "Cookie: $COMPUTE_COOKIE" \
     -H "Content-Type: application/oracle-compute-v3+json" \
     -H "Accept: application/oracle-compute-v3+json" \
     "$API_URL"storage/volume/Compute-$IDNTTY/$USR_LOGIN/boot_$i;

  echo "deleting repo disk for $i node...";
  curl -X DELETE \
     -H "Cookie: $COMPUTE_COOKIE" \
     -H "Content-Type: application/oracle-compute-v3+json" \
     -H "Accept: application/oracle-compute-v3+json" \
     "$API_URL"storage/volume/Compute-$IDNTTY/$USR_LOGIN/repo_$i;
done;

echo ""
echo "-------------------------------------"
echo "Wait until all storages are online..."
echo "-------------------------------------"

