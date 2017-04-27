#!/bin/bash
# Sample call  sh ./status-storage.sh "$COMPUTE_COOKIE" "$API_URL"
# API_URL is at: Oracle Cloud Services -> Service Details:Oracle Compute Cloud Service: REST Endpoint
# COMPUTE_COOKIE is retrieved with
# curl -i -X POST -H "Content-Type: application/oracle-compute-v3+json" -d '{"user":"Compute-apiscotas/mochoa@scotas.com","password":"-------"}' "$API_URL"authenticate/

set -e
echo ""
echo "---------------------------"
echo "Getting Disks node status..."
echo "---------------------------"
COMPUTE_COOKIE=$1
API_URL=$2
for i in $(awk '{print $1}' cloud.hosts); do
  echo "";
  echo "getting boot disk for $i node...";
  curl -X GET \
     -H "Cookie: $COMPUTE_COOKIE" \
     -H "Content-Type: application/oracle-compute-v3+json" \
     -H "Accept: application/oracle-compute-v3+json" \
     "$API_URL"storage/volume/Compute-apiscotas/mochoa@scotas.com/boot_$i;

  echo "";
  echo "getting repo disk for $i node...";
  curl -X GET \
     -H "Cookie: $COMPUTE_COOKIE" \
     -H "Content-Type: application/oracle-compute-v3+json" \
     -H "Accept: application/oracle-compute-v3+json" \
     "$API_URL"storage/volume/Compute-apiscotas/mochoa@scotas.com/repo_$i;
done;

echo ""
echo "-------------------------------------"
echo "Wait until all storages are online..."
echo "-------------------------------------"

