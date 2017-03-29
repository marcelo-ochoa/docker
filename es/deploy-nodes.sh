#!/bin/bash
# Sample call  sh ./deploy-nodes.sh $COMPUTE_COOKIE $API_URL
# API_URL is at: Oracle Cloud Services -> Service Details:Oracle Compute Cloud Service: REST Endpoint
# COMPUTE_COOKIE is retrieved with
# curl -i -X POST -H "Content-Type: application/oracle-compute-v3+json" -d '{"user":"Compute-tdlscotas/mochoa@scotas.com","password":"-------"}' "$API_URL"authenticate/
set -e
echo ""
echo "-----------------"
echo "Creating Nodes..."
echo "-----------------"
COMPUTE_COOKIE=$1
API_URL=$2
for i in $(awk '{print $1}' cloud.hosts); do
  echo "creating $i node...";
  echo "{
  \"instances\": [
    {
      \"shape\": \"oc3\",
      \"networking\" : {
          \"eth0\" : {
            \"seclists\" : [ \"/Compute-tdlscotas/default/default\" ],
            \"nat\" : \"ippool:/oracle/public/ippool\"
          }
      },
      \"imagelist\": \"/Compute-tdlscotas/mochoa@scotas.com/Ubuntu.16.10.amd64.20170307\",
      \"name\": \"/Compute-tdlscotas/mochoa@scotas.com/$i\",
      \"storage_attachments\" : [ {
          \"volume\" : \"/Compute-tdlscotas/mochoa@scotas.com/boot_$i\",
          \"index\" : 1
        }, {
          \"volume\" : \"/Compute-tdlscotas/mochoa@scotas.com/repo_$i\",
          \"index\" : 2
        } ],
      \"boot_order\" : [ 1 ],
      \"hostname\" : \"$i.compute-tdlscotas.oraclecloud.internal.\",
      \"label\": \"docker node\",
      \"sshkeys\": [
        \"/Compute-tdlscotas/mochoa@scotas.com/ubnt\"
      ],
      \"tags\" : [ \"docker\", \"node\" ]
    }
  ]
}" > /tmp/data.json;
  curl -i -X POST \
     -H "Cookie: $COMPUTE_COOKIE" \
     -H "Content-Type: application/oracle-compute-v3+json" \
     -H "Accept: application/oracle-compute-v3+json" \
     -d "@/tmp/data.json" "$2"launchplan/;
done;

echo ""
echo "-------------------------------------------------------------------------------"
echo "Wait until all instances are online and copy public IPs to cloud.hosts file ..."
echo "-------------------------------------------------------------------------------"

