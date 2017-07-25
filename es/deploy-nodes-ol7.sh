#!/bin/bash
# Sample call  sh ./deploy-nodes.sh "$COMPUTE_COOKIE" "$API_URL" "apiscotas" "mochoa@scotas.com"
# API_URL is at: Oracle Cloud Services -> Service Details:Oracle Compute Cloud Service: REST Endpoint
# COMPUTE_COOKIE is retrieved with
# curl -i -X POST -H "Content-Type: application/oracle-compute-v3+json" -d '{"user":"Compute-$IDNTTY/$USR_LOGIN","password":"-------"}' "$API_URL"authenticate/
set -e
echo ""
echo "-----------------"
echo "Creating Nodes..."
echo "-----------------"
COMPUTE_COOKIE=$1
API_URL=$2
IDNTTY=$3
USR_LOGIN=$4
for i in $(awk '{print $1}' cloud.hosts); do
  SHAPE=$(grep $i cloud.hosts|awk '{print $4}');
  echo "";
  echo "creating $i with shape $SHAPE ...";
  echo "{
  \"instances\": [
    {
      \"shape\": \"$SHAPE\",
      \"networking\" : {
          \"eth0\" : {
            \"seclists\" : [ \"/Compute-$IDNTTY/default/default\" ],
            \"nat\" : \"ippool:/oracle/public/ippool\"
          }
      },
      \"imagelist\": \"/oracle/public/OL_7.2_UEKR4_x86_64\",
      \"name\": \"/Compute-$IDNTTY/$USR_LOGIN/$i\",
      \"storage_attachments\" : [ {
          \"volume\" : \"/Compute-$IDNTTY/$USR_LOGIN/boot_$i\",
          \"index\" : 1
        }, {
          \"volume\" : \"/Compute-$IDNTTY/$USR_LOGIN/repo_$i\",
          \"index\" : 2
        } ],
      \"boot_order\" : [ 1 ],
      \"hostname\" : \"$i.compute-$IDNTTY.oraclecloud.internal.\",
      \"label\": \"docker node\",
      \"sshkeys\": [
        \"/Compute-$IDNTTY/$USR_LOGIN/Docker\"
      ],
      \"tags\" : [ \"docker\", \"node\" ]
    }
  ]
}" > /tmp/data.json;
  curl -X POST \
     -H "Cookie: $COMPUTE_COOKIE" \
     -H "Content-Type: application/oracle-compute-v3+json" \
     -H "Accept: application/oracle-compute-v3+json" \
     -d "@/tmp/data.json" "$API_URL"launchplan/;
done;

echo ""
echo "-------------------------------------------------------------------------------"
echo "Wait until all instances are online and copy public IPs to cloud.hosts file ..."
echo "-------------------------------------------------------------------------------"

