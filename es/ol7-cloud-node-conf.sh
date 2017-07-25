echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sysctl -p
# echo "auto eth1
#      iface eth1 inet dhcp" > /etc/network/interfaces.d/60-swarm-init.cfg
mkfs.xfs -L repo -n ftype=1 /dev/xvdc
echo "LABEL=repo         /var/lib/docker   xfs defaults     0 0">> /etc/fstab
mkdir -p /var/lib/docker
mount /var/lib/docker
yum update -y
yum install --enablerepo=ol7_addons -y docker-engine nfs-utils
systemctl enable docker
systemctl start docker
usermod -G docker -a opc

