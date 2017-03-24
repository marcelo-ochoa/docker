echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sysctl -p
echo "auto eth1
     iface eth1 inet dhcp" > /etc/network/interfaces.d/60-swarm-init.cfg
mkfs.ext4 -L repo /dev/xvdc
echo "LABEL=repo         /var/lib/docker   ext4 defaults     0 0">> /etc/fstab
mkdir -p /var/lib/docker
mount /var/lib/docker
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y dist-upgrade
apt-get install -y --no-install-recommends \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual
curl -fsSL https://apt.dockerproject.org/gpg | apt-key add -
add-apt-repository \
       "deb https://apt.dockerproject.org/repo/ \
       ubuntu-$(lsb_release -cs) \
       main"
apt-get update
apt-get -y install docker-engine
usermod -G docker -a ubuntu

