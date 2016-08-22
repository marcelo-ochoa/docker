docker run --name localrepo --hostname localrepo --detach=true --publish=80:80 localrepo:1.0.0
echo "Local repo is at: http://$(docker inspect --format='{{ .NetworkSettings.IPAddress }}' localrepo):80/"
